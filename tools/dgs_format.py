# Lua Formatter for DGS library, created by iManGaaX

from __future__ import annotations

import argparse
import difflib
import os
import re
import subprocess
import sys

KEYWORDS = frozenset("and break do else elseif end false for function goto if in local nil not or repeat return then true until while".split())

MULTI_OPS = ("...", "..", "==", "~=", "<=", ">=", "::")
SINGLE_OPS = set("+-*/%^#<>=(){}[];:,.")

NAME_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
NUM_RE = re.compile(
    r"0[xX][0-9a-fA-F]+"
    r"|\d+\.(?!\.)\d*(?:[eE][+-]?\d+)?"
    r"|\.\d+(?:[eE][+-]?\d+)?"
    r"|\d+(?:[eE][+-]?\d+)?"
)

EXPR_END_TEXTS = frozenset((")", "]", "}", "...", "end", "true", "false", "nil"))
STMT_KEYWORDS = frozenset(("local", "if", "for", "while", "repeat", "return", "break", "goto", "function"))
HEADER_END_TEXTS = frozenset(("then", "do", "repeat", "else", ";", "end", "until"))
CLOSER_TEXTS = frozenset(("end", "else", "elseif", "until"))
OPENER_TEXTS = frozenset(("then", "do", "repeat", "else", ";"))
OTHER_OPERATORS = frozenset(("==", "~=", "<=", ">=", "<", ">", "..", "+", "-", "*", "/", "%", "^", "#"))
BLOCK_KINDS = frozenset(("if", "for", "while", "repeat", "do", "function"))
BLANK_BEFORE_KINDS = frozenset(("if", "for", "while", "repeat", "do", "function", "return"))

class Tok(object):
    __slots__ = ("kind", "text", "lead", "pos")

    def __init__(self, kind, text, lead, pos):
        self.kind = kind
        self.text = text
        self.lead = lead
        self.pos = pos

    def __repr__(self):
        return "Tok(%s, %r)" % (self.kind, self.text)


def _long_level(src, i):
    if i >= len(src) or src[i] != "[":
        return None
    j = i + 1
    level = 0
    while j < len(src) and src[j] == "=":
        level += 1
        j += 1
    if j < len(src) and src[j] == "[":
        return level
    return None


def _long_end(src, i, level):
    close = "]" + "=" * level + "]"
    j = src.find(close, i)
    return len(src) if j < 0 else j + len(close)


def lex(src):
    toks = []
    n = len(src)
    i = 0
    lead_start = 0
    while i < n:
        ch = src[i]
        if ch in " \t\r\n\f\v":
            i += 1
            continue
        lead = src[lead_start:i]
        if ch == "[":
            level = _long_level(src, i)
            if level is not None:
                end = _long_end(src, i, level)
                toks.append(Tok("string", src[i:end], lead, i))
                i = end
                lead_start = i
                continue
        if src.startswith("--", i):
            level = _long_level(src, i + 2)
            if level is not None:
                end = _long_end(src, i + 2, level)
                toks.append(Tok("comment", src[i:end], lead, i))
                i = end
            else:
                j = i + 2
                while j < n and src[j] not in "\r\n":
                    j += 1
                toks.append(Tok("comment", src[i:j].rstrip(), lead, i))
                i = j
            lead_start = i
            continue
        if ch in "\"'":
            j = i + 1
            while j < n:
                if src[j] == "\\":
                    j += 2
                    continue
                if src[j] == ch:
                    j += 1
                    break
                if src[j] in "\r\n":
                    break
                j += 1
            toks.append(Tok("string", src[i:j], lead, i))
            i = j
            lead_start = i
            continue
        m = NAME_RE.match(src, i)
        if m:
            text = m.group(0)
            toks.append(Tok("keyword" if text in KEYWORDS else "name", text, lead, i))
            i = m.end()
            lead_start = i
            continue
        m = NUM_RE.match(src, i)
        if m:
            toks.append(Tok("number", m.group(0), lead, i))
            i = m.end()
            lead_start = i
            continue
        for op in MULTI_OPS:
            if src.startswith(op, i):
                toks.append(Tok("op", op, lead, i))
                i += len(op)
                break
        else:
            toks.append(Tok("op", ch, lead, i))
            i += 1
        lead_start = i
    return toks


def token_signature(toks):
    return [(t.kind, t.text) for t in toks]


def token_signature_portable(toks):
    return [(t.kind, t.text.rstrip() if t.kind == "comment" else t.text) for t in toks]


WHITESPACE = " \t\r\n\f\v"


def strip_insignificant(src):
    out = []
    i = 0
    n = len(src)
    while i < n:
        ch = src[i]
        if ch in WHITESPACE:
            i += 1
            continue
        if src.startswith("--", i):
            level = _long_level(src, i + 2)
            if level is not None:
                end = _long_end(src, i + 2, level)
                out.append(src[i:end])
                i = end
                continue
            j = i + 2
            while j < n and src[j] not in "\r\n":
                j += 1
            out.append(src[i:j].rstrip())
            i = j
            continue
        if ch == "[":
            level = _long_level(src, i)
            if level is not None:
                end = _long_end(src, i, level)
                out.append(src[i:end])
                i = end
                continue
        if ch in "\"'":
            j = i + 1
            while j < n:
                if src[j] == "\\":
                    j += 2
                    continue
                if src[j] == ch:
                    j += 1
                    break
                if src[j] in "\r\n":
                    break
                j += 1
            out.append(src[i:j])
            i = j
            continue
        out.append(ch)
        i += 1
    return "".join(out)


def normalize_eol(text):
    return text.replace("\r\n", "\n").replace("\r", "\n")


def newline_count(text):
    return len(re.findall(r"\r\n|\n|\r", text))


def ends_expression(tok):
    return tok.kind in ("name", "number", "string") or tok.text in EXPR_END_TEXTS


def ends_statement(tok):
    if ends_expression(tok):
        return True
    return tok.text in HEADER_END_TEXTS


def detect_indent(src):
    tabs = 0
    spaces = 0
    for line in src.split("\n"):
        stripped = line.strip()
        if not stripped:
            continue
        ws = line[: len(line) - len(line.lstrip(" \t"))]
        if ws.startswith("\t"):
            tabs += 1
        elif ws.startswith("    "):
            spaces += 1
    return "\t" if tabs >= spaces else "    "


def normalize_tokens(sig_toks):
    out = []
    for t in sig_toks:
        if t.kind == "number":
            out.append("<n>")
        elif t.kind == "string":
            out.append("<s>")
        else:
            out.append(t.text)
    return "".join(out)


class Options(object):
    def __init__(self):
        self.cluster = True
        self.split = True
        self.operators = False


class FormatError(Exception):
    pass


class SourceLine(object):
    __slots__ = ("idxs", "kind", "depth", "indent_level", "region", "orig_indent", "after", "text", "is_comment", "stmt_open_before", "stmt_open_after")

    def __init__(self, idxs):
        self.idxs = idxs
        self.kind = "stmt"
        self.depth = 0
        self.indent_level = 0
        self.region = 0
        self.orig_indent = ""
        self.after = 1
        self.text = ""
        self.is_comment = False
        self.stmt_open_before = False
        self.stmt_open_after = False


def plan_breaks(toks, opts):
    n = len(toks)
    breaks = [False] * n
    kinds = ["cont"] * n
    breaks[0] = True
    kinds[0] = "stmt"

    def force(i, kind):
        if i >= n:
            return
        breaks[i] = True
        if kind == "block" or kinds[i] == "cont":
            kinds[i] = kind

    for i in range(1, n):
        if newline_count(toks[i].lead):
            breaks[i] = True

    for i in range(1, n):
        if "\n" in toks[i - 1].text and not newline_count(toks[i].lead):
            breaks[i] = True

    sig = [i for i, t in enumerate(toks) if t.kind != "comment"]
    paren = 0
    pending_func = False
    func_open = None
    is_sig_close = {}

    for k, i in enumerate(sig):
        t = toks[i]
        text = t.text
        prev = toks[sig[k - 1]] if k else None
        if text == "function" and t.kind == "keyword":
            pending_func = True
        elif text == "(":
            paren += 1
            if pending_func:
                func_open = paren
                pending_func = False
        elif text == ")":
            if func_open is not None and paren == func_open:
                is_sig_close[i] = True
                func_open = None
            paren = max(paren - 1, 0)
        if text in CLOSER_TEXTS and t.kind in ("keyword", "op"):
            force(i, "block")
        if prev is not None:
            if prev.text in OPENER_TEXTS:
                force(i, "stmt")
            if is_sig_close.get(sig[k - 1]):
                force(i, "stmt")
            if opts.split and ends_expression(prev):
                if t.kind == "name":
                    force(i, "stmt")
                elif t.kind == "keyword" and text in STMT_KEYWORDS:
                    force(i, "stmt")
    return breaks, kinds


def build_lines(toks, breaks):
    lines = []
    cur = []
    for i in range(len(toks)):
        if breaks[i] and cur:
            lines.append(SourceLine(cur))
            cur = []
        cur.append(i)
    if cur:
        lines.append(SourceLine(cur))
    return lines


def annotate(lines, toks, kinds, src):
    indent_char = detect_indent(src)
    block_stack = []
    region_stack = [0]
    next_region = [1]
    paren_depth = 0
    pending_func = False
    func_open = None
    stmt_open = False

    for line in lines:
        first = toks[line.idxs[0]]
        line.is_comment = all(toks[i].kind == "comment" for i in line.idxs)
        line.kind = kinds[line.idxs[0]]
        line.depth = len(block_stack)
        line.region = region_stack[-1]
        if line.kind == "block":
            line.indent_level = max(len(block_stack) - 1, 0)
        else:
            line.indent_level = len(block_stack)
        lead = first.lead
        nl = max(lead.rfind("\n"), lead.rfind("\r"))
        line.orig_indent = lead[nl + 1 :]

        starts_elseif = first.kind == "keyword" and first.text == "elseif"
        line.stmt_open_before = stmt_open
        last_sig = None
        for i in line.idxs:
            t = toks[i]
            text = t.text
            if t.kind == "comment":
                continue
            last_sig = t
            if text == "function" and t.kind == "keyword":
                pending_func = True
            elif text == "(":
                paren_depth += 1
                if pending_func:
                    func_open = paren_depth
                    pending_func = False
            elif text == ")":
                closes_sig = func_open is not None and paren_depth == func_open
                paren_depth = max(paren_depth - 1, 0)
                if closes_sig:
                    func_open = None
                    block_stack.append("function")
                    region_stack.append(next_region[0])
                    next_region[0] += 1
            elif t.kind == "keyword":
                if text == "then":
                    if not starts_elseif:
                        block_stack.append("if")
                        region_stack.append(next_region[0])
                        next_region[0] += 1
                elif text == "do":
                    block_stack.append("do")
                    region_stack.append(next_region[0])
                    next_region[0] += 1
                elif text == "repeat":
                    block_stack.append("repeat")
                    region_stack.append(next_region[0])
                    next_region[0] += 1
                elif text == "end" or text == "until":
                    if not block_stack:
                        raise FormatError("unbalanced %r" % text)
                    block_stack.pop()
                    region_stack.pop()
                elif text == "else" or text == "elseif":
                    if len(region_stack) < 1:
                        raise FormatError("unbalanced %r" % text)
                    region_stack[-1] = next_region[0]
                    next_region[0] += 1
        stmt_open = last_sig is not None and not ends_statement(last_sig)
        line.stmt_open_after = stmt_open

    if block_stack:
        raise FormatError("unbalanced block, %d block(s) still open" % len(block_stack))
    if paren_depth:
        raise FormatError("unbalanced parenthesis (%d open)" % paren_depth)
    return indent_char


class Item(object):
    __slots__ = ("first_line", "body_line", "region", "kind", "sig", "ends_block")

    def __init__(self):
        self.first_line = 0
        self.body_line = 0
        self.region = 0
        self.kind = "other"
        self.sig = "other"
        self.ends_block = False


def classify(line, toks):
    idxs = [i for i in line.idxs if toks[i].kind != "comment"]
    if not idxs:
        return "comment", "comment"
    first = toks[idxs[0]]
    kind = None
    if first.kind == "keyword" and first.text == "local":
        kind = "local"
        if len(idxs) > 1 and toks[idxs[1]].text == "function":
            kind = "function"
    elif first.kind == "keyword" and first.text in BLOCK_KINDS | {"return", "break", "goto"}:
        kind = first.text
    else:
        kind = None

    if kind == "local":
        count = 0
        depth = 0
        for i in idxs[1:]:
            t = toks[i]
            if t.text in ("(", "[", "{"):
                depth += 1
            elif t.text in (")", "]", "}"):
                depth -= 1
            elif depth == 0 and t.text == "=":
                break
            elif depth == 0 and t.kind == "name":
                count += 1
        return kind, "local:%d" % count

    if kind is not None:
        return kind, kind

    depth = 0
    eq_at = None
    paren_at = None
    for pos, i in enumerate(idxs):
        t = toks[i]
        text = t.text
        if text in ("(", "[", "{"):
            if text == "(" and depth == 0 and paren_at is None:
                paren_at = pos
            depth += 1
        elif text in (")", "]", "}"):
            depth -= 1
        elif depth == 0 and text == "=" and eq_at is None:
            eq_at = pos
            break
    if eq_at is not None:
        return "assign", "set:" + normalize_tokens([toks[i] for i in idxs[:eq_at]])
    if first.text == "(":
        return "call", "call:()"
    if paren_at is not None:
        return "call", "call:" + normalize_tokens([toks[i] for i in idxs[:paren_at]])
    return "other", "other:" + normalize_tokens([toks[i] for i in idxs[:1]])


def build_items(lines, toks):
    items = []
    cur = None
    k = 0
    total = len(lines)
    while k < total:
        line = lines[k]
        if line.kind == "block":
            cur = None
            k += 1
            continue
        if line.kind == "stmt":
            cur = Item()
            cur.first_line = k
            cur.body_line = k
            cur.region = line.region
            items.append(cur)
            k += 1
            continue
        if line.is_comment:
            j = k
            while j < total and lines[j].is_comment:
                j += 1
            nxt = lines[j] if j < total else None
            if nxt is not None and nxt.kind == "stmt":
                cur = Item()
                cur.first_line = k
                cur.body_line = j
                cur.region = nxt.region
                items.append(cur)
                k = j + 1
                continue
            if cur is None:
                cur = Item()
                cur.first_line = k
                cur.body_line = k
                cur.region = line.region
                cur.kind = "comment"
                cur.sig = "comment"
                items.append(cur)
            k += 1
            continue
        k += 1

    for item in items:
        if item.kind == "comment":
            continue
        if item.body_line < len(lines):
            kind, sig = classify(lines[item.body_line], toks)
            item.kind = kind
            item.sig = sig
            item.ends_block = kind in BLOCK_KINDS
    return items


def apply_blank_rules(lines, items, opts):
    by_region = {}
    for item in items:
        by_region.setdefault(item.region, []).append(item)

    stats = {"blank_before": 0, "blank_after_block": 0, "blank_cluster": 0}
    for region, lst in by_region.items():
        run = []
        for k, item in enumerate(lst):
            if k and lst[k - 1].sig == item.sig:
                run.append(run[-1] + 1)
            else:
                run.append(1)
        for k in range(1, len(lst)):
            prev_item = lst[k - 1]
            item = lst[k]
            reason = None
            if item.kind in BLANK_BEFORE_KINDS:
                reason = "blank_before"
            elif prev_item.ends_block:
                reason = "blank_after_block"
            elif (
                opts.cluster
                and item.sig != prev_item.sig
                and run[k - 1] >= 2
                and item.kind != "comment"
            ):
                reason = "blank_cluster"
            if reason is None:
                continue
            target = item.first_line - 1
            if target >= 0:
                if lines[target].after < 2:
                    stats[reason] += 1
                lines[target].after = max(lines[target].after, 2)
    return stats


def render_gap(prev, cur, opts):
    if prev.kind == "comment":
        return cur.lead if cur.lead else " "
    if cur.lead:
        return cur.lead
    if prev.text in (",", ";"):
        return " "
    if cur.text == "=" and prev.text != "=":
        return " "
    if prev.text == "=":
        return " "
    if opts.operators and (cur.text in OTHER_OPERATORS or prev.text in OTHER_OPERATORS):
        return " "
    return ""


def render_line(line, toks, opts):
    before = [i for i in line.idxs]
    parts = []
    prev = None
    for i in before:
        t = toks[i]
        if prev is None:
            parts.append(t.text)
        else:
            parts.append(render_gap(prev, t, opts) + t.text)
        prev = t
    return "".join(parts)


def format_text(src, opts=None):
    opts = opts or Options()
    bom = ""
    body = src
    if body.startswith("\ufeff"):
        bom, body = "\ufeff", body[1:]
    if not body.strip():
        return bom + body, {}

    toks = lex(body)
    if not toks:
        return bom + body, {}

    eol = "\r\n" if "\r\n" in body else "\n"
    had_trailing_newline = body.endswith("\n") or body.endswith("\r")

    breaks, kinds = plan_breaks(toks, opts)
    lines = build_lines(toks, breaks)
    indent_char = annotate(lines, toks, kinds, body)
    for k in range(1, len(lines)):
        if newline_count(toks[lines[k].idxs[0]].lead) >= 2:
            lines[k - 1].after = 2
    items = build_items(lines, toks)
    stats = apply_blank_rules(lines, items, opts)

    for line in lines:
        line.text = render_line(line, toks, opts)
        if line.kind == "block" or line.kind == "stmt":
            line.orig_indent = indent_char * line.indent_level
        elif line.is_comment and not line.stmt_open_before:
            line.orig_indent = indent_char * line.indent_level

    out = []
    for k, line in enumerate(lines):
        after = line.after
        if k == len(lines) - 1:
            after = 1 if had_trailing_newline else 0
        out.append(line.orig_indent + line.text + eol * after)
    rendered = "".join(out)
    result = bom + rendered

    before = token_signature(lex(body))
    after = token_signature(lex(rendered))
    if before != after:
        raise FormatError("token stream changed: %s" % _first_difference(before, after))
    stats["lines"] = len(lines)
    stats["blank_lines"] = sum(1 for line in lines if line.after == 2)
    return result, stats


def _first_difference(before, after):
    for k in range(min(len(before), len(after))):
        if before[k] != after[k]:
            return "token %d: %r vs %r (context %r)" % (k, before[k], after[k], before[max(0, k - 3):k + 3])
    return "length %d vs %d" % (len(before), len(after))


def git_head_source(root, path):
    rel = os.path.relpath(path, root).replace("\\", "/")
    try:
        raw = subprocess.check_output(["git", "show", "HEAD:" + rel], cwd=root, stderr=subprocess.DEVNULL)
    except (OSError, subprocess.CalledProcessError):
        return None
    return raw.decode("utf-8", "surrogateescape")


def verify_against_head(root, paths, quiet):
    ok = 0
    failures = []
    skipped = 0
    tokens = 0
    for path in iter_lua_files(root, paths):
        head = git_head_source(root, path)
        if head is None:
            skipped += 1
            continue
        rel = os.path.relpath(path, root).replace("\\", "/")
        before_toks = token_signature_portable(lex(normalize_eol(head)))
        after_toks = token_signature_portable(lex(normalize_eol(read_source(path))))
        tokens += len(before_toks)
        if before_toks != after_toks:
            failures.append((rel, "token stream: " + _first_difference(before_toks, after_toks)))
            continue
        before_chars = strip_insignificant(normalize_eol(head))
        after_chars = strip_insignificant(normalize_eol(read_source(path)))
        if before_chars != after_chars:
            at = next((k for k in range(min(len(before_chars), len(after_chars))) if before_chars[k] != after_chars[k]), min(len(before_chars), len(after_chars)))
            failures.append((rel, "characters: %r vs %r" % (before_chars[max(0, at - 25):at + 25], after_chars[max(0, at - 25):at + 25])))
            continue
        ok += 1
        if not quiet:
            print("ok    %s" % rel)
    for rel, why in failures:
        print("FAIL  %s -> %s" % (rel, why))
    print("-- %d file(s) identical to HEAD, %d failure(s), %d untracked file(s), %d token(s) compared" % (ok, len(failures), skipped, tokens))
    if failures:
        print("   PROGRAM LOGIC DIFFERS - do not commit")
        return 1
    print("   token streams and characters are identical: logic is unchanged")
    return 0


def iter_lua_files(root, extra_paths=None):
    skip = {".git", ".freebuff"}
    if extra_paths:
        for path in extra_paths:
            if os.path.isdir(path):
                for base, dirs, files in os.walk(path):
                    dirs[:] = [d for d in dirs if d not in skip]
                    for name in sorted(files):
                        if name.endswith(".lua"):
                            yield os.path.join(base, name)
            elif os.path.isfile(path):
                yield path
        return
    for base, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in skip]
        for name in sorted(files):
            if name.endswith(".lua"):
                yield os.path.join(base, name)


def read_source(path):
    with open(path, "rb") as handle:
        raw = handle.read()
    return raw.decode("utf-8", "surrogateescape")


def write_source(path, text):
    with open(path, "wb") as handle:
        handle.write(text.encode("utf-8", "surrogateescape"))


def main(argv=None):
    parser = argparse.ArgumentParser(description="Whitespace only Lua formatter")
    parser.add_argument("paths", nargs="*", help="files or directories (default: the repo)")
    parser.add_argument("--check", action="store_true", help="list files that would change")
    parser.add_argument("--diff", action="store_true", help="print a unified diff, write nothing")
    parser.add_argument("--write", action="store_true", help="rewrite the files in place")
    parser.add_argument("--verify", action="store_true", help="prove that the working tree holds the same program as git HEAD")
    parser.add_argument("--no-cluster", action="store_true")
    parser.add_argument("--no-split", action="store_true")
    parser.add_argument("--operators", action="store_true")
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args(argv)

    opts = Options()
    opts.cluster = not args.no_cluster
    opts.split = not args.no_split
    opts.operators = args.operators

    root = os.getcwd()
    if args.verify:
        return verify_against_head(root, args.paths or None, args.quiet)
    changed = []
    failed = []
    totals = {"lines": 0, "blank_lines": 0, "blank_before": 0, "blank_after_block": 0, "blank_cluster": 0}

    for path in iter_lua_files(root, args.paths or None):
        src = read_source(path)
        try:
            result, stats = format_text(src, opts)
        except FormatError as exc:
            failed.append((path, str(exc)))
            continue
        if stats:
            for key in totals:
                totals[key] += stats.get(key, 0)
        rel = os.path.relpath(path, root).replace("\\", "/")
        if result == src:
            continue
        changed.append(rel)
        if args.diff:
            text = "".join(difflib.unified_diff(src.splitlines(True), result.splitlines(True), "a/" + rel, "b/" + rel))
            sys.stdout.buffer.write(text.encode("utf-8", "surrogateescape"))
            sys.stdout.buffer.flush()
        if args.write:
            write_source(path, result)

    if not args.quiet:
        for rel in changed:
            if not args.diff:
                print("would change: %s" % rel)
    for path, why in failed:
        print("FAILED (untouched): %s -> %s" % (path, why))
    print("-- %d file(s) %s, %d failure(s); %d lines planned, %d blank lines" % (len(changed), "rewritten" if args.write else ("diffed" if args.diff else "would change"), len(failed), totals["lines"], totals["blank_lines"])
    )
    if not args.diff:
        print("   blank lines: %d before a block, %d after a block, %d between runs" % (totals["blank_before"], totals["blank_after_block"], totals["blank_cluster"]))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

/*
TODO:
- なんかいろいろリファクタリング
- KILLみたいなのでTLEを打ち切るようにする
- もっとソースとかジャッジのコンパイルエラーとか拾えるようにする
- どんな情報を表示するか/ログに残すかとか考えないといけない
*/

import std.process;
import std.stdio;
import std.file;
import std.path;
import std.conv;

void main () {
    /* カレントディレクトリにあるディレクトリはテストが入ってると仮定 */
    foreach (VerifyProblemsDir; dirEntries(getcwd(), SpanMode.shallow)) {
        if (!isDir(VerifyProblemsDir.name)) continue;
        foreach (ProblemDir; dirEntries(VerifyProblemsDir.name, SpanMode.shallow)) {
            run_test(ProblemDir);
        }
    }
}

auto run_test (DirEntry ProblemDir) {
    if (
        !chainPath(ProblemDir.name, "in").exists ||
        !chainPath(ProblemDir.name, "out").exists ||
        !chainPath(ProblemDir.name, "verify.d").exists ||
        !chainPath(ProblemDir.name, "judge.d").exists
        )
    { return; }
    if (
        !chainPath(ProblemDir.name, "in").isDir ||
        !chainPath(ProblemDir.name, "out").isDir
        )
    { return; }

    writeln("必要ファイル群はあったよ");

    /* verify */
    foreach (testcase_in; dirEntries(chainPath(ProblemDir.name, "in").to!string, SpanMode.shallow)) {
        if (!chainPath(ProblemDir.name, "out", testcase_in.name).exists) continue; /* error: output file is not found. */
        verify(ProblemDir, testcase_in);
    }
}

auto verify (DirEntry ProblemDir, DirEntry testcase) {
    writeln("trying verify ", testcase, "...");

    auto input = File(testcase, "r");
    /* パイプだと多分容量制限があるので、しゃーなしカレントに出力ファイルを作成 */
    string OutputFilePath = "out";
    {
        auto solver = spawnProcess(["rdmd", chainPath(ProblemDir.name, "verify.d").to!string], input, File(OutputFilePath, "w"));
        writeln("solving...");
        scope (exit) wait(solver);
    }

    auto judge = spawnProcess(["rdmd", chainPath(ProblemDir.name, "judge.d").to!string, testcase.name], File(OutputFilePath, "r"), std.stdio.stdout);
    scope (exit) {
        wait(judge);
        remove(OutputFilePath);
    }
}

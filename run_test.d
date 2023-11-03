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
import std.typecons;

void main () {
    /* カレントディレクトリにあるディレクトリはテストが入ってると仮定 */
    foreach (FeatureDir; dirEntries(getcwd(), SpanMode.shallow)) {
        if (!isDir(FeatureDir.name)) continue;
        auto log = File(chainPath(FeatureDir, "latestresult.log").to!string, "w");
        foreach (ProblemDir; dirEntries(FeatureDir.name, SpanMode.shallow)) {
            auto result = runTestWithProblem(ProblemDir);
            /* 一つの問題に対してのverifyログを記録 */
            /* TODO */
        }
    }
}

enum ProblemExitCode : string {
    ProblemNotFound = "Problems were not found.",
    BadFormatTestCase = "There was a test case that did not meet the format.",
    AC = "Accepted all test cases.",
    WA = "There was at least one wrong answer.",
}

enum JudgeStatus : string {
    AC = "AC",
    WA = "WA",
    TLE = "TLE",
    Undefined = "Undefined",
}

alias ProblemResult = Tuple!(ProblemExitCode, "ExitCode", string[], "TestCaseNames", JudgeStatus[], "JudgeStatus");

ProblemResult runTestWithProblem (DirEntry ProblemDir) {
    if (
        !chainPath(ProblemDir.name, "in").exists ||
        !chainPath(ProblemDir.name, "out").exists ||
        !chainPath(ProblemDir.name, "verify.d").exists ||
        !chainPath(ProblemDir.name, "judge.d").exists ||
        !chainPath(ProblemDir.name, "in").isDir ||
        !chainPath(ProblemDir.name, "out").isDir
        )
    { return ProblemResult(ProblemExitCode.ProblemNotFound, [], []);}

    /* verify */
    bool hasBadTestCase = false;
    bool hasWA = false;
    ProblemResult result;

    foreach (testcase_in; dirEntries(chainPath(ProblemDir.name, "in").to!string, SpanMode.shallow)) {
        if (!chainPath(ProblemDir.name, "out", testcase_in.name).exists) {
            result.TestCaseNames ~= chainPath(ProblemDir.name, "in").to!string;
            result.JudgeStatus ~= JudgeStatus.Undefined;
            continue;
        }
        verify(ProblemDir, testcase_in);
    }

    /* 不正なテストケースが優先 */
    if (hasWA) result.ExitCode = ProblemExitCode.WA;
    if (hasBadTestCase) result.ExitCode = ProblemExitCode.BadFormatTestCase;
    return result;
}

JudgeStatus verify (DirEntry ProblemDir, DirEntry testcase) {
    auto input = File(testcase, "r");
    /* パイプだと多分容量制限があるので、しゃーなしカレントに出力ファイルを作成 */
    string OutputFilePath = chainPath(ProblemDir.name, "result").to!string;
    {
        auto solver = spawnProcess(["rdmd", chainPath(ProblemDir.name, "verify.d").to!string], input, File(OutputFilePath, "w"));
        //writeln("solving...");
        scope (exit) wait(solver);
    }

    auto judge = spawnProcess(["rdmd", chainPath(ProblemDir.name, "judge.d").to!string, testcase.name], File(OutputFilePath, "r"));
    scope (exit) {
        wait(judge);
        remove(OutputFilePath);
    }
}

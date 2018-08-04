/*
  An example Clang analyze checker

  This checker tests Objective-C method declaration and complains if its name
  starts with `_` but doesn't contain any other `_`.
 */

#include <algorithm>
#include <string>

#include "clang/StaticAnalyzer/Core/BugReporter/BugType.h"
#include "clang/StaticAnalyzer/Core/Checker.h"
#include "clang/StaticAnalyzer/Core/CheckerRegistry.h"
#include "clang/StaticAnalyzer/Core/PathSensitive/CheckerContext.h"

#include "configure.h"

using namespace clang;
using namespace ento;

class ExampleChecker : public Checker<check::ASTDecl<ObjCMethodDecl>> {
public:
  void checkASTDecl(const ObjCMethodDecl *d, AnalysisManager &mgr,
                    BugReporter &br) const {
    std::string name{d->getNameAsString()};
    if (IsAppleName(name)) {
      PathDiagnosticLocation l{
          PathDiagnosticLocation::create(d, br.getSourceManager())};
      br.EmitBasicReport(
          d, this,
          "A method name may conflict with Apple's internal method names.",
          "Example", "Rename to avoid Apple's internal method names.", l);
    }
  }

private:
  bool IsAppleName(std::string &name) const {
    return name[0] == '_' && count(name.begin(), name.end(), '_') < 2;
  }
};

extern "C" void clang_registerCheckers(CheckerRegistry &registry) {
  registry.addChecker<ExampleChecker>("example.Checker",
                                      "An example Clang analyzer checker.");
}

extern "C" const char clang_analyzerAPIVersionString[] =
    CLANG_PLUGINS_EXAMPLES_CLANG_VERSION;

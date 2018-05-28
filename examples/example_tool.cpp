/*
  An example Clang tool.

  This tool rewrites Objective-C method declarations that name starts with `_`
  but doesn't contain any other `_`.
  This tool doesn't rewrite any references like callers.
 */

#include <algorithm>
#include <string>

#include "clang/AST/AST.h"
#include "clang/AST/ASTConsumer.h"
#include "clang/AST/RecursiveASTVisitor.h"
#include "clang/Frontend/ASTConsumers.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/FrontendActions.h"
#include "clang/Rewrite/Core/Rewriter.h"
#include "clang/Tooling/CommonOptionsParser.h"
#include "clang/Tooling/Tooling.h"

using namespace clang;
using namespace clang::driver;
using namespace clang::tooling;

class ExampleRewriteVisitor
    : public RecursiveASTVisitor<ExampleRewriteVisitor> {
public:
  explicit ExampleRewriteVisitor(Rewriter &rewriter) : rewriter_{rewriter} {}

  bool VisitObjCMethodDecl(ObjCMethodDecl *d) {
    std::string name{d->getNameAsString()};
    if (IsAppleName(name)) {
      llvm::errs() << "* Rewrite: " << name << "\n";
      // Insert `_private` in front of its selector name.
      rewriter_.InsertTextBefore(d->getSelectorStartLoc(), "_private");
    }
    return true;
  }

private:
  bool IsAppleName(std::string &name) const {
    return name[0] == '_' && count(name.begin(), name.end(), '_') < 2;
  }

  Rewriter &rewriter_;
};

class ExampleRewriteConsumer : public ASTConsumer {
public:
  explicit ExampleRewriteConsumer(Rewriter &rewriter) : rewriter_{rewriter} {}

  virtual void HandleTranslationUnit(ASTContext &c) {
    ExampleRewriteVisitor v{rewriter_};
    v.TraverseDecl(c.getTranslationUnitDecl());
  }

private:
  Rewriter &rewriter_;
};

class ExampleFrontendAction : public ASTFrontendAction {
public:
  std::unique_ptr<ASTConsumer> CreateASTConsumer(CompilerInstance &ci,
                                                 StringRef file) override {
    llvm::errs() << "* CreateASTConsumer: " << file << "\n";
    rewriter_.setSourceMgr(ci.getSourceManager(), ci.getLangOpts());
    return llvm::make_unique<ExampleRewriteConsumer>(rewriter_);
  }

  void EndSourceFileAction() override {
    SourceManager &sm{rewriter_.getSourceMgr()};
    llvm::errs() << "* EndSourceFileAction: "
                 << sm.getFileEntryForID(sm.getMainFileID())->getName() << "\n";
    rewriter_.getEditBuffer(sm.getMainFileID()).write(llvm::outs());
  }

private:
  Rewriter rewriter_;
};

static llvm::cl::OptionCategory _option_category{"Example options"};

int main(int argc, const char **argv) {
  CommonOptionsParser parser{argc, argv, _option_category};
  ClangTool tool{parser.getCompilations(), parser.getSourcePathList()};
  return tool.run(newFrontendActionFactory<ExampleFrontendAction>().get());
}

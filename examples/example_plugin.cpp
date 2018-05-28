/*
  An example Clang plugin.

  This plugin prints Objective-C method declarations that name starts with `_`
  but doesn't contain any other `_`.
 */

#include <string>

#include "clang/AST/AST.h"
#include "clang/AST/ASTConsumer.h"
#include "clang/AST/RecursiveASTVisitor.h"
#include "clang/Frontend/ASTConsumers.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/FrontendPluginRegistry.h"

using namespace clang;

class ExampleVisitor : public RecursiveASTVisitor<ExampleVisitor> {
public:
  bool VisitObjCMethodDecl(ObjCMethodDecl *d) {
    std::string name{d->getNameAsString()};
    if (IsAppleName(name)) {
      llvm::errs() << name << "\n";
    }
    return true;
  }

private:
  bool IsAppleName(std::string &name) const {
    return name[0] == '_' && count(name.begin(), name.end(), '_') < 2;
  }
};

class ExampleConsumer : public ASTConsumer {
public:
  virtual void HandleTranslationUnit(clang::ASTContext &c) {
    ExampleVisitor v{};
    v.TraverseDecl(c.getTranslationUnitDecl());
  }
};

class ExamplePluginAction : public PluginASTAction {
public:
  std::unique_ptr<ASTConsumer> CreateASTConsumer(CompilerInstance &ci,
                                                 llvm::StringRef) {
    return llvm::make_unique<ExampleConsumer>();
  }

  bool ParseArgs(const CompilerInstance &ci,
                 const std::vector<std::string> &args) {
    return true;
  }

  ActionType getActionType() { return AddBeforeMainAction; }
};

static FrontendPluginRegistry::Add<ExamplePluginAction> X("example", "Example");

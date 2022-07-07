# Ltex Docs example.
```
dictionary
    {"en-US": ["adaptivity", "precomputed", "subproblem"], "de-DE": ["B-Splines", ":/path/to/externalFile.txt"]}
disabledRules
    {"en-US": ["EN_QUOTES", "UPPERCASE_SENTENCE_START", ":/path/to/externalFile.txt"]}
enabledRules
    {"en-GB": ["PASSIVE_VOICE", "OXFORD_SPELLING_NOUNS", ":/path/to/externalFile.txt"]}
hiddenFalsePositives
    {"en-US": [":/path/to/externalFile.txt"]}
```

- `_ltex.addToDictionary` is executed by the client when it should add words to the dictionary by adding them to ltex.dictionary.
- `_ltex.disableRules` is executed by the client when it should disable rules by adding the rule IDs to ltex.disabledRules.
- `_ltex.hideFalsePositives` is executed by the client when it should hide false positives by adding them to ltex.hiddenFalsePositives.

# Ltex Docs interfaces.
```typescript
interface AddToDictionaryCommandParams {
    // URI of the document.
    // Words to add to the dictionary, specified as lists of strings by language.
    uri: string;
    words: {
               [language: string]: string[];
           };
}
type AddToDictionaryCommandResult = null;
```

```typescript
interface DisableRulesCommandParams {
    // URI of the document.
    // IDs of the LanguageTool rules to disable, specified as lists of strings by language.
    uri: string;
    ruleIds: {
                 [language: string]: string[];
             };
}
type DisableRulesCommandResult = null;
```

```typescript
interface HideFalsePositivesCommandParams {
    // URI of the document.
    // False positives to hide, specified as lists of JSON strings by language.
    uri: string;
    falsePositives: {
                        [language: string]: string[];
                    };
}
type HideFalsePositivesCommandResult = null;
```

# Vscode-ltex functions.
```typescript
private addToDictionary(params: any): void {
  this.addToLanguageSpecificSetting(Code.Uri.parse(params.uri), 'dictionary', params.words);
  this.checkCurrentDocument();
}

private disableRules(params: any): void {
  this.addToLanguageSpecificSetting(Code.Uri.parse(params.uri), 'disabledRules', params.ruleIds);
  this.checkCurrentDocument();
}

private hideFalsePositives(params: any): void {
  this.addToLanguageSpecificSetting(Code.Uri.parse(params.uri), 'hiddenFalsePositives',
      params.falsePositives);
  this.checkCurrentDocument();
}

private addToLanguageSpecificSetting(uri: Code.Uri, settingName: string,
      entries: LanguageSpecificSettingValue): void {
  const resourceConfig: Code.WorkspaceConfiguration =
      // #if TARGET == 'vscode'
      Code.workspace.getConfiguration('ltex.configurationTarget', uri);
      // #elseif TARGET == 'coc.nvim'
      // Code.workspace.getConfiguration('ltex.configurationTarget', uri.toString());
      // #endif
  const scopeString: string | undefined = resourceConfig.get(settingName);
  let scopes: Code.ConfigurationTarget[];

  if ((scopeString == null) || scopeString.startsWith('workspaceFolder')) {
    scopes = [Code.ConfigurationTarget.WorkspaceFolder, Code.ConfigurationTarget.Workspace,
        Code.ConfigurationTarget.Global];
  } else if (scopeString.startsWith('workspace')) {
    scopes = [Code.ConfigurationTarget.Workspace, Code.ConfigurationTarget.Global];
  } else if (scopeString.startsWith('user')) {
    scopes = [Code.ConfigurationTarget.Global];
  } else {
    Logger.error(i18n('invalidValueForConfigurationTarget', scopeString));
    return;
  }

  if ((scopeString == null) || scopeString.endsWith('ExternalFile')) {
    this.addToLanguageSpecificSettingExternalFile(uri, settingName, scopes, entries);
  } else {
    this.addToLanguageSpecificSettingInternalSetting(uri, settingName, scopes, entries);
  }
}

private async checkCurrentDocument(): Promise<boolean> {
  if (this._languageClient == null) {
    Code.window.showErrorMessage(i18n('ltexNotInitialized'));
    return Promise.resolve(false);
  }

  // #if TARGET == 'vscode'
  const textEditor: Code.TextEditor | undefined = Code.window.activeTextEditor;

  if (textEditor == null) {
    Code.window.showErrorMessage(i18n('noEditorOpenToCheckDocument'));
    return Promise.resolve(false);
  }

  return this.checkDocument(textEditor.document.uri, textEditor.document.languageId,
      textEditor.document.getText());
  // #elseif TARGET == 'coc.nvim'
  // const document: Code.Document = await Code.workspace.document;

  // return this.checkDocument(Code.Uri.parse(document.uri), document.filetype,
      // document.content);
  // #endif
}
```

# LSP-config settings.
```lua
dictionary = {
    ["es-AR"] = readFiles(Dictionary_file["pt-BR"] or {}),
};
disabledRules = {
    ["es-AR"] = readFiles(DisabledRules_file["pt-BR"] or {}),
};
hiddenFalsePositives = {
    ["es-AR"] = readFiles(FalsePositives_file["pt-BR"] or {}),
};
```

# Vscode files:
```
ltex.dictionary.en-US.txt, ltex.dictionary.en-US.txt
    Errorr
    Misssspelling
ltex.disabledRules.es-AR.txt
    MORFOLOGIK_RULE_ES
    INCORRECT_SPACES
ltex.hiddenFalsePositives.es-AR.txt
    {"rule":"MORFOLOGIK_RULE_ES","sentence":"^\\QMal escribido.\\E$"}
    {"rule":"DET_FEM_NOM_FEM","sentence":"^\\QLa agua.\\E$"}
```

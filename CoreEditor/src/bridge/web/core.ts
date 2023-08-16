import { WebModule } from '../webModule';
import {
  ReplaceGranularity,
  resetEditor,
  clearEditor,
  getEditorText,
  insertText,
  replaceText,
  handleMouseEntered,
  handleMouseExited,
} from '../../core';

/**
 * @shouldExport true
 * @invokePath core
 * @overrideModuleName WebBridgeCore
 */
export interface WebModuleCore extends WebModule {
  resetEditor({ text, readOnly }: { text: string; readOnly: boolean }): void;
  clearEditor(): void;
  getEditorText(): string;
  insertText({ text, from, to }: { text: string; from: CodeGen_Int; to: CodeGen_Int }): void;
  replaceText({ text, granularity }: { text: string; granularity: ReplaceGranularity }): void;
  handleMouseEntered({ clientX, clientY }: { clientX: number; clientY: number } ): void;
  handleMouseExited({ clientX, clientY }: { clientX: number; clientY: number } ): void;
}

export class WebModuleCoreImpl implements WebModuleCore {
  resetEditor({ text, readOnly }: { text: string; readOnly: boolean }): void {
    resetEditor(text, readOnly);
  }

  clearEditor(): void {
    clearEditor();
  }

  getEditorText(): string {
    return getEditorText();
  }

  insertText({ text, from, to }: { text: string; from: CodeGen_Int; to: CodeGen_Int }): void {
    insertText(text, from, to);
  }

  replaceText({ text, granularity }: { text: string; granularity: ReplaceGranularity }): void {
    replaceText(text, granularity);
  }

  handleMouseEntered({ clientX, clientY }: { clientX: number; clientY: number }): void {
    handleMouseEntered(clientX, clientY);
  }

  handleMouseExited({ clientX, clientY }: { clientX: number; clientY: number }): void {
    handleMouseExited(clientX, clientY);
  }
}

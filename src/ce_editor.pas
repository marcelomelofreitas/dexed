unit ce_editor;

{$I ce_defines.inc}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, lcltype, Graphics, SynEditKeyCmds,
  ComCtrls, SynEditHighlighter, ExtCtrls, Menus, SynMacroRecorder, dialogs,
  SynPluginSyncroEdit, SynEdit, SynHighlighterMulti, ce_dialogs,
  ce_widget, ce_interfaces, ce_synmemo, ce_dlang, ce_common, ce_dcd, ce_observer,
  ce_sharedres, ce_controls, ce_writableComponent, ce_dsgncontrols;

type

  TCEEditorWidget = class;

  TCEPagesOptions = class(TWritableLfmTextComponent, ICEEditableOptions, ICEEditableShortCut)
  private
    fEditorWidget: TCEEditorWidget;
    fPageButtons: TCEPageControlButtons;
    fPageOptions: TCEPageControlOptions;
    fMoveLeft: TShortCut;
    fMoveRight: TShortCut;
    fNextPage: TShortCut;
    fPrevPage: TShortCut;
    fDetectModuleName: boolean;
    fShCount: integer;
    function optionedWantCategory(): string;
    function optionedWantEditorKind: TOptionEditorKind;
    function optionedWantContainer: TPersistent;
    procedure optionedEvent(event: TOptionEditorEvent);
    function optionedOptionsModified: boolean;
    //
    function scedWantFirst: boolean;
    function scedWantNext(out category, identifier: string; out aShortcut: TShortcut): boolean;
    procedure scedSendItem(const category, identifier: string; aShortcut: TShortcut);
    procedure scedSendDone;
  published
    property pageButtons: TCEPageControlButtons read fPageButtons write fPageButtons;
    property pageOptions: TCEPageControlOptions read fPageOptions write fPageOptions;
    property nextPage: TShortCut read fNextPage write fNextPage;
    property previousPage: TShortCut read fPrevPage write fPrevPage;
    property moveLeft: TShortCut read fMoveLeft write fMoveLeft;
    property moveRight: TShortCut read fMoveRight write fMoveRight;
    property detectModuleName: boolean read fDetectModuleName write fDetectModuleName default true;
  public
    procedure assign(source: TPersistent); override;
    procedure assignTo(target: TPersistent); override;
    constructor construct(editorWidg: TCEEditorWidget);
    destructor Destroy; override;
  end;

  { TCEEditorWidget }

  TCEEditorWidget = class(TCEWidget, ICEDocumentObserver, ICEMultiDocHandler, ICEProjectObserver)
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    mnuedSortLines: TMenuItem;
    mnuedNextCarea: TMenuItem;
    mnuedPrevCarea: TMenuItem;
    mnuedLowcase: TMenuItem;
    mnuedUpcase: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    mnuedRename: TMenuItem;
    mnuedInvAllNone: TMenuItem;
    mnuedComm: TMenuItem;
    mnuedPrev: TMenuItem;
    mnuedNext: TMenuItem;
    mnuedCallTip: TMenuItem;
    mnuedDdoc: TMenuItem;
    mnuedCopy: TMenuItem;
    mnuedCut: TMenuItem;
    mnuedPaste: TMenuItem;
    MenuItem4: TMenuItem;
    mnuedUndo: TMenuItem;
    mnuedRedo: TMenuItem;
    MenuItem7: TMenuItem;
    mnuedJum2Decl: TMenuItem;
    macRecorder: TSynMacroRecorder;
    editorStatus: TStatusBar;
    mnuEditor: TPopupMenu;
    procedure mnuedNextCareaClick(Sender: TObject);
    procedure mnuedPrevCareaClick(Sender: TObject);
    procedure mnuedLowcaseClick(Sender: TObject);
    procedure mnuedSortLinesClick(Sender: TObject);
    procedure mnuedUpcaseClick(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure mnuedRenameClick(Sender: TObject);
    procedure mnuedInvAllNoneClick(Sender: TObject);
    procedure mnuedCommClick(Sender: TObject);
    procedure mnuedPrevClick(Sender: TObject);
    procedure mnuedNextClick(Sender: TObject);
    procedure mnuedCallTipClick(Sender: TObject);
    procedure mnuedCopyClick(Sender: TObject);
    procedure mnuedCutClick(Sender: TObject);
    procedure mnuedDdocClick(Sender: TObject);
    procedure mnuEditorPopup(Sender: TObject);
    procedure mnuedPasteClick(Sender: TObject);
    procedure mnuedUndoClick(Sender: TObject);
    procedure mnuedRedoClick(Sender: TObject);
    procedure mnuedJum2DeclClick(Sender: TObject);
  protected
    procedure updateDelayed; override;
    procedure updateImperative; override;
    procedure setToolBarFlat(value: boolean); override;
  private
    fDetectModuleName: boolean;
    fOptions: TCEPagesOptions;
    pageControl: TCEPageControl;
    fKeyChanged: boolean;
    fDoc: TCESynMemo;
    fProj: ICECommonProject;
    fTokList: TLexTokenList;
    fModStart: boolean;
    fLastCommand: TSynEditorCommand;
    procedure PageControlChanged(Sender: TObject);
    procedure PageControlChanging(Sender: TObject; var AllowChange: Boolean);
    procedure updateStatusBar;
    procedure updatePageCaption;
    procedure pageBtnAddCLick(Sender: TObject);
    procedure pageCloseBtnClick(Sender: TObject);
    procedure lexFindToken(const token: PLexToken; out stop: boolean);
    procedure memoKeyPress(Sender: TObject; var Key: char);
    procedure memoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure memoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure memoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure memoCtrlClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure memoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure getSymbolLoc;
    procedure focusedEditorChanged;
    procedure memoCmdProcessed(Sender: TObject; var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: pointer);
    procedure setDetectModuleName(value: boolean);
    //
    procedure docNew(document: TCESynMemo);
    procedure docClosing(document: TCESynMemo);
    procedure docFocused(document: TCESynMemo);
    procedure docChanged(document: TCESynMemo);
    //
    procedure projNew(project: ICECommonProject);
    procedure projChanged(project: ICECommonProject);
    procedure projClosing(project: ICECommonProject);
    procedure projFocused(project: ICECommonProject);
    procedure projCompiling(project: ICECommonProject);
    procedure projCompiled(project: ICECommonProject; success: boolean);
    //
    function SingleServiceName: string;
    function documentCount: Integer;
    function getDocument(index: Integer): TCESynMemo;
    function findDocument(fname: string): TCESynMemo;
    procedure openDocument(fname: string);
    function closeDocument(index: Integer): boolean;
    function closeDocument(doc: TCESynMemo): boolean;
  public
    constructor create(aOwner: TComponent); override;
    destructor destroy; override;
    function closeQuery: boolean; override;
  end;

implementation
{$R *.lfm}

uses
  ce_lcldragdrop;
const
  optname = 'editorpages.txt';

{$REGION TCEPagesOptions -------------------------------------------------------}
constructor TCEPagesOptions.construct(editorWidg: TCEEditorWidget);
var
  fname: string;
begin
  fEditorWidget := editorWidg;
  inherited create(editorWidg);
  EntitiesConnector.addObserver(self);
  //
  fDetectModuleName := true;
  fname := getCoeditDocPath + optname;
  if fname.fileExists then
  begin
    loadFromFile(fname);
    assignTo(fEditorWidget);
  end
  else assign(fEditorWidget);
end;

destructor TCEPagesOptions.Destroy;
begin
  saveToFile(getCoeditDocPath + optname);
  EntitiesConnector.removeObserver(self);
  inherited;
end;

procedure TCEPagesOptions.assign(source: TPersistent);
begin
  if source = fEditorWidget then
  begin
    fPageButtons := fEditorWidget.pageControl.buttons;
    fPageOptions := fEditorWidget.pageControl.options;
    fDetectModuleName:= fEditorWidget.fDetectModuleName;
  end
  else inherited;
end;

procedure TCEPagesOptions.assignTo(target: TPersistent);
begin
  if target = fEditorWidget then
  begin
    fEditorWidget.pageControl.buttons := fPageButtons;
    fEditorWidget.pageControl.options := fPageOptions;
    fEditorWidget.setDetectModuleName(fDetectModuleName);
  end
  else inherited;
end;

function TCEPagesOptions.optionedWantCategory(): string;
begin
  exit('Editor pages')
end;

function TCEPagesOptions.optionedWantEditorKind: TOptionEditorKind;
begin
  exit(oekGeneric);
end;

function TCEPagesOptions.optionedWantContainer: TPersistent;
begin
  exit(self);
end;

procedure TCEPagesOptions.optionedEvent(event: TOptionEditorEvent);
begin
  case event of
    oeeAccept: assignTo(fEditorWidget);
    oeeCancel: assign(fEditorWidget);
  end;
end;

function TCEPagesOptions.optionedOptionsModified: boolean;
begin
  exit(false);
end;

function TCEPagesOptions.scedWantFirst: boolean;
begin
  fShCount := 0;
  exit(true);
end;

function TCEPagesOptions.scedWantNext(out category, identifier: string; out aShortcut: TShortcut): boolean;
begin
  category := 'Editor pages';
  case fShCount of
    0: begin identifier := 'Select next page'; aShortcut:= fNextPage; end;
    1: begin identifier := 'Select previous page'; aShortcut:= fPrevPage; end;
    2: begin identifier := 'Move page left'; aShortcut:= fMoveLeft; end;
    3: begin identifier := 'Move page right'; aShortcut:= fMoveRight; end;
  end;
  fShCount += 1;
  result := fShCount <> 4;
end;

procedure TCEPagesOptions.scedSendItem(const category, identifier: string; aShortcut: TShortcut);
begin
  if fShCount = 4 then
    fShCount := 0;
  case fShCount of
    0: fNextPage := aShortcut;
    1: fPrevPage := aShortcut;
    2: fMoveLeft := aShortcut;
    3: fMoveRight:= aShortcut;
  end;
end;

procedure TCEPagesOptions.scedSendDone;
begin
  fShCount := 0;
end;
{$ENDREGION}

{$REGION Standard Comp/Obj------------------------------------------------------}
constructor TCEEditorWidget.create(aOwner: TComponent);
begin
  inherited;
  toolbarVisible:=false;
  fDetectModuleName:=true;
  //
  pageControl := TCEPageControl.Create(self);
  pageControl.Parent := Content;
  pageControl.align := alClient;
  pageControl.onChanged:= @PageControlChanged;
  pageControl.onChanging:=@PageControlChanging;
  pageControl.closeButton.OnClick:=@pageCloseBtnClick;
  pageControl.addButton.OnClick:=@pageBtnAddCLick;
  pageControl.OnDragDrop:= @ddHandler.DragDrop;
  pageControl.OnDragOver:= @ddHandler.DragOver;
  AssignPng(pageControl.moveLeftButton, 'GO_PREVIOUS');
  AssignPng(pageControl.moveRightButton, 'GO_NEXT');
  AssignPng(pageControl.addButton, 'DOCUMENT_ADD');
  AssignPng(pageControl.closeButton, 'DOCUMENT_DELETE');
  AssignPng(pageControl.splitButton, 'SPLITTER');

  fTokList := TLexTokenList.Create;
  //
  AssignPng(mnuedCopy.Bitmap, 'COPY');
  AssignPng(mnuedCut.Bitmap, 'CUT');
  AssignPng(mnuedPaste.Bitmap, 'PASTE');
  AssignPng(mnuedUndo.Bitmap, 'ARROW_UNDO');
  AssignPng(mnuedRedo.Bitmap, 'ARROW_REDO');
  AssignPng(mnuedJum2Decl.Bitmap, 'ARROW_SHOE');
  AssignPng(mnuedCopy.Bitmap, 'COPY');
  AssignPng(mnuedNext.Bitmap, 'GO_NEXT');
  AssignPng(mnuedPrev.Bitmap, 'GO_PREVIOUS');
  AssignPng(mnuedRename.Bitmap, 'PENCIL');
  AssignPng(mnuedUpcase.Bitmap, 'CASE');
  AssignPng(mnuedLowcase.Bitmap, 'CASE');
  AssignPng(mnuedNextCarea.Bitmap, 'GO_NEXT');
  AssignPng(mnuedPrevCarea.Bitmap, 'GO_PREVIOUS');
  AssignPng(mnuedSortLines.Bitmap, 'SORT_AZ');
  //
  EntitiesConnector.addObserver(self);
  EntitiesConnector.addSingleService(self);
  //
  fOptions:= TCEPagesOptions.construct(self);
end;

destructor TCEEditorWidget.destroy;
var
  i: integer;
begin
  EntitiesConnector.removeObserver(self);
  for i := PageControl.PageCount-1 downto 0 do
    if PageControl.Pages[i].ControlCount > 0 then
      if (PageControl.Pages[i].Controls[0] is TCESynMemo) then
        PageControl.Pages[i].Controls[0].Free;
  fTokList.Free;
  fOptions.Free;
  inherited;
end;

function TCEEditorWidget.closeQuery: boolean;
begin
  result := inherited and Parent.isNil;
end;

procedure TCEEditorWidget.setToolBarFlat(value: boolean);
begin
  inherited setToolBarFlat(value);
  if value then
    pageControl.options := pageControl.options + [poFlatButtons]
  else
    pageControl.options := pageControl.options - [poFlatButtons];
end;
{$ENDREGION}

{$REGION ICEDocumentObserver ---------------------------------------------------}
procedure TCEEditorWidget.docNew(document: TCESynMemo);
var
  pge: TCEPage;
begin
  pge := pageControl.addPage;
  //
  document.Align := alClient;
  document.Parent := pge;
  //
  document.OnKeyDown := @memoKeyDown;
  document.OnKeyUp := @memoKeyUp;
  document.OnKeyPress := @memoKeyPress;
  document.OnMouseDown := @memoMouseDown;
  document.OnMouseMove := @memoMouseMove;
  document.OnClickLink := @memoCtrlClick;
  document.OnCommandProcessed:= @memoCmdProcessed;
  //
  fDoc := document;
  fDoc.setFocus;
  focusedEditorChanged;
  updateImperative;
end;

procedure TCEEditorWidget.docClosing(document: TCESynMemo);
begin
  if document.isNil then
    exit;
  document.Parent := nil;
  if document = fDoc then
    fDoc := nil;
  pageControl.deletePage(pageControl.pageIndex);
  updateImperative;
end;

procedure TCEEditorWidget.docFocused(document: TCESynMemo);
begin
  if fDoc.isNotNil and pageControl.currentPage.isNotNil and
    (pageControl.currentPage.Caption = '<new document>') then
      updatePageCaption;
  if document = fDoc then exit;
  fDoc := document;
  focusedEditorChanged;
  updateImperative;
end;

procedure TCEEditorWidget.docChanged(document: TCESynMemo);
begin
  if fDoc <> document then
    exit;
  fKeyChanged := true;
  beginDelayedUpdate;
end;
{$ENDREGION}

{$REGION ICECommonProject ------------------------------------------------------}
procedure TCEEditorWidget.projNew(project: ICECommonProject);
begin
end;

procedure TCEEditorWidget.projChanged(project: ICECommonProject);
begin
end;

procedure TCEEditorWidget.projClosing(project: ICECommonProject);
begin
  if fProj = project then
    fProj := nil;
end;

procedure TCEEditorWidget.projFocused(project: ICECommonProject);
begin
  fProj := project;
end;

procedure TCEEditorWidget.projCompiling(project: ICECommonProject);
begin
end;

procedure TCEEditorWidget.projCompiled(project: ICECommonProject; success: boolean);
begin
end;
{$ENDREGION}

{$REGION ICEMultiDocHandler ----------------------------------------------------}
function TCEEditorWidget.SingleServiceName: string;
begin
  exit('ICEMultiDocHandler');
end;

function TCEEditorWidget.documentCount: Integer;
begin
  exit(PageControl.PageCount);
end;

function TCEEditorWidget.getDocument(index: Integer): TCESynMemo;
begin
  exit(TCESynMemo(pageControl.Pages[index].Controls[0]));
end;

function TCEEditorWidget.findDocument(fname: string): TCESynMemo;
var
  i: Integer;
begin
  for i := 0 to PageControl.PageCount-1 do
  begin
    result := getDocument(i);
    if result.fileName = fname then
      exit;
  end;
  result := nil;
end;

procedure TCEEditorWidget.openDocument(fname: string);
var
  doc: TCESynMemo;
begin
  doc := findDocument(fname);
  if doc.isNotNil then begin
    PageControl.currentPage := TCEPage(doc.Parent);
    exit;
  end;
  doc := TCESynMemo.Create(nil);
  fDoc.loadFromFile(fname);
  if assigned(fProj) and (fProj.filename = fDoc.fileName) then
  begin
    if fProj.getFormat = pfNative then
      fDoc.Highlighter := LfmSyn
    else
      fDoc.Highlighter := JsSyn;
  end;
end;

function TCEEditorWidget.closeDocument(index: Integer): boolean;
var
  doc: TCESynMemo;
begin
  doc := getDocument(index);
  if doc.isNil then exit(false);
  if (doc.modified or (doc.fileName = doc.tempFilename)) and
    (dlgFileChangeClose(doc.fileName, UnsavedFile) = mrCancel) then exit(false);
  doc.disableFileDateCheck:=true;
  pageControl.pageIndex:=index;
  doc.Free;
  result := true;
end;

function TCEEditorWidget.closeDocument(doc: TCESynMemo): boolean;
var
  page: TCEPage = nil;
begin
  page := TCEPage(doc.Parent);
  if page.isNil then
    exit(false);
  exit(closeDocument(page.index));
end;
{$ENDREGION}

{$REGION PageControl/Editor things ---------------------------------------------}
procedure TCEEditorWidget.pageCloseBtnClick(Sender: TObject);
begin
  closeDocument(PageControl.PageIndex);
end;

procedure TCEEditorWidget.pageBtnAddCLick(Sender: TObject);
begin
  TCESynMemo.Create(nil);
  pageControl.currentPage.Caption:='<new document>';
end;

procedure TCEEditorWidget.setDetectModuleName(value: boolean);
var
  i, j: integer;
begin
  if fDetectModuleName = value then
    exit;
  fDetectModuleName:=value;
  j := pageControl.pageIndex;
  if j = -1 then
    exit;
  for i:= 0 to pageControl.pageCount-1 do
  begin
    pageControl.pageIndex:= i;
    updatePageCaption;
  end;
  pageControl.pageIndex:= j;
end;

procedure TCEEditorWidget.focusedEditorChanged;
begin
  if fDoc.isNil then exit;
  //
  macRecorder.Editor:= fDoc;
  fDoc.PopupMenu := mnuEditor;
  fDoc.hideCallTips;
  fDoc.hideDDocs;
  if (pageControl.currentPage.Caption = '') or
    (pageControl.currentPage.Caption ='<new document>') then
  begin
    fKeyChanged := true;
    beginDelayedUpdate;
  end;
end;

procedure TCEEditorWidget.PageControlChanged(Sender: TObject);
begin
  if fDoc.isNil then exit;
  fDoc.hideCallTips;
  fDoc.hideDDocs;
end;

procedure TCEEditorWidget.PageControlChanging(Sender: TObject; var AllowChange: Boolean);
begin
  if fDoc.isNil then exit;
  fDoc.hideCallTips;
  fDoc.hideDDocs;
end;

procedure TCEEditorWidget.memoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  sh: TShortCut;
begin
  case Key of
    VK_CLEAR,VK_RETURN,VK_BACK :
      fKeyChanged := true;
    VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT:
      if Shift = [] then
        updateImperative;
    else begin
      // note: keys conflict can lead to a lose of focus, i.e shortcut
      // to select next page cant be repeated.
      sh := KeyToShortCut(Key, shift);
      if sh = fOptions.fNextPage then
      begin
        pageControl.pageIndex:= (pageControl.pageIndex + 1) mod pageControl.pageCount;
      end
      else if sh = fOptions.fPrevPage then
      begin
        if pageControl.pageIndex - 1 < 0 then
          pageControl.pageIndex:= pageControl.pageCount - 1
        else
          pageControl.pageIndex:= pageControl.pageIndex - 1;
      end
      else if sh = fOptions.fMoveLeft then
        pageControl.movePageLeft
      else if sh = fOptions.fMoveRight then
        pageControl.movePageRight;
    end;
  end;
  if fKeyChanged then
    beginDelayedUpdate;
end;

procedure TCEEditorWidget.memoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case fLastCommand of
    ecSelectionStart..ecSelectionEnd: updateImperative;
    ecLeft..ecHalfWordRight: updateImperative;
  end;
end;

procedure TCEEditorWidget.memoCmdProcessed(Sender: TObject; var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: pointer);
begin
  fLastCommand := Command;
  //
  case Command of
    ecJumpToDeclaration:
      getSymbolLoc;
    ecRecordMacro:
    begin
      if macRecorder.State = msStopped then
        macRecorder.RecordMacro(fDoc)
      else
        macRecorder.Stop;
      updateImperative;
    end;
    ecPlayMacro:
    begin
      macRecorder.Stop;
      macRecorder.PlaybackMacro(fDoc);
      updateImperative;
    end;
  end;
end;

procedure TCEEditorWidget.memoKeyPress(Sender: TObject; var Key: char);
begin
  fKeyChanged := true;
  beginDelayedUpdate;
end;

procedure TCEEditorWidget.memoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  updateImperative;
end;

procedure TCEEditorWidget.memoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if not (ssLeft in Shift) then exit;
  beginDelayedUpdate;
end;

procedure TCEEditorWidget.memoCtrlClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  getSymbolLoc;
end;

procedure TCEEditorWidget.getSymbolLoc;
var
  page: TCEPage;
  srcpos, i, sum, linelen: Integer;
  fname: string;
  len: byte;
begin
  if not DcdWrapper.available then exit;
  //
  DcdWrapper.getDeclFromCursor(fname, srcpos);
  if (fname <> fDoc.fileName) and fname.fileExists then
  begin
    page := pageControl.splitPage;
    if assigned(page) then
    begin
      fDoc := TCESynMemo(page.Controls[0]);
      if fDoc.fileName <> fname then
        openDocument(fname);
    end
    else openDocument(fname);
  end;
  if srcpos <> -1 then
  begin
    sum := 0;
    len := getLineEndingLength(fDoc.fileName);
    for i := 0 to fDoc.Lines.Count-1 do
    begin
      linelen := fDoc.Lines[i].length;
      if sum + linelen + len > srcpos then
      begin
        fDoc.CaretY := i + 1;
        fDoc.CaretX := srcpos - sum + len;
        fDoc.SelectWord;
        fDoc.EnsureCursorPosVisible;
        break;
      end;
      sum += linelen;
      sum += len;
    end;
  end;
end;

procedure TCEEditorWidget.updateStatusBar;
const
  modstr: array[boolean] of string = ('...', 'MODIFIED');
begin
  if fDoc = nil then
  begin
    editorStatus.Panels[0].Text := '';
    editorStatus.Panels[1].Text := '';
    editorStatus.Panels[2].Text := '';
    editorStatus.Panels[3].Text := '';
    editorStatus.Panels[4].Text := '';
  end else
  begin
    editorStatus.Panels[0].Text := format('%d : %d | %d', [fDoc.CaretY, fDoc.CaretX, fDoc.SelEnd - fDoc.SelStart]);
    editorStatus.Panels[1].Text := modstr[fDoc.modified];
    if macRecorder.State = msRecording then
      editorStatus.Panels[2].Text := 'recording macro'
    else if macRecorder.IsEmpty then
      editorStatus.Panels[2].Text := 'no macro'
    else
      editorStatus.Panels[2].Text := 'macro ready';
    if fDoc.ReadOnly then
    begin
      editorStatus.Panels[3].Width:= 120;
      editorStatus.Panels[3].Text := '(read-only)';
    end else
      editorStatus.Panels[3].Width:= 0;
    editorStatus.Panels[4].Text := fDoc.fileName;
  end;
end;

procedure TCEEditorWidget.updatePageCaption;
var
  md: string = '<new document>';
begin
  if fDoc.isNotNil then
  begin
    if fDetectModuleName then
    begin
      if fDoc.isDSource then
      begin
        lex(fDoc.Lines.Text, fTokList, @lexFindToken, [lxoNoComments]);
        md := getModuleName(fTokList);
        fTokList.Clear;
        if md.isEmpty then
          md := fDoc.fileName.extractFileName;
      end
      else if fDoc.fileName.fileExists then
        md := fDoc.fileName.extractFileName
    end
      else if fDoc.fileName.fileExists then
        md := fDoc.fileName.extractFileName
  end;
  pageControl.currentPage.Caption := md;
end;

procedure TCEEditorWidget.updateImperative;
begin
  updateStatusBar;
  if fDoc.isNotNil then
    updatePageCaption;
end;

procedure TCEEditorWidget.updateDelayed;
begin
  if fDoc = nil then
    exit;
  updateStatusBar;
  if not fKeyChanged then
    exit;
  if fDoc.isNotNil then
    updatePageCaption;
end;

procedure TCEEditorWidget.lexFindToken(const token: PLexToken; out stop: boolean);
begin
  if (token^.kind = ltkKeyword) and (token^.data = 'module') then
  begin
    fModStart := true;
    exit;
  end;
  if fModStart and (token^.kind = ltkSymbol) and (token^.data = ';') then
  begin
    stop := true;
    fModStart := false;
  end;
end;
{$ENDREGION}

{$REGION Editor context menu ---------------------------------------------------}
procedure TCEEditorWidget.mnuedCopyClick(Sender: TObject);
begin
  if fDoc.isNotNil then
    fDoc.ExecuteCommand(ecCopy, '', nil);
end;

procedure TCEEditorWidget.mnuedCallTipClick(Sender: TObject);
begin
  if fDoc.isNil then
    exit;
  mnuEditor.Close;
  fDoc.hideDDocs;
  if not fDoc.IsDSource and not fDoc.alwaysAdvancedFeatures then
      exit;
  fDoc.showCallTips;
end;

procedure TCEEditorWidget.mnuedCommClick(Sender: TObject);
begin
  if fDoc.isNotNil then
    fDoc.CommandProcessor(ecCommentSelection, '', nil);
end;

procedure TCEEditorWidget.mnuedPrevClick(Sender: TObject);
begin
  if fDoc.isNotNil then
    fDoc.CommandProcessor(ecPreviousLocation, '', nil);
end;

procedure TCEEditorWidget.mnuedNextClick(Sender: TObject);
begin
  if fDoc.isNotNil then
    fDoc.CommandProcessor(ecNextLocation, '', nil);
end;

procedure TCEEditorWidget.mnuedInvAllNoneClick(Sender: TObject);
begin
  if fDoc.isNil then
    exit;
  if not fDoc.IsDSource and not fDoc.alwaysAdvancedFeatures then
    exit;
  fDoc.CommandProcessor(ecSwapVersionAllNone, '', nil);
end;

procedure TCEEditorWidget.MenuItem5Click(Sender: TObject);
begin
  if fDoc.isNil then
    exit;
  if not fDoc.IsDSource and not fDoc.alwaysAdvancedFeatures then
    exit;
  with TSaveDialog.Create(nil) do
  try
    if execute then
    begin
      fTokList.Clear;
      lex(fDoc.Text, fTokList, nil);
      fTokList.saveToFile(FileName);
      fTokList.Clear;
    end;
  finally
    free;
  end;
end;

procedure TCEEditorWidget.mnuedUpcaseClick(Sender: TObject);
begin
  if fDoc.isNotNil then
    fDoc.CommandProcessor(ecUpperCaseWordOrSel, #0, nil);
end;

procedure TCEEditorWidget.mnuedLowcaseClick(Sender: TObject);
begin
  if fDoc.isNotNil then
    fDoc.CommandProcessor(ecLowerCaseWordOrSel, #0, nil);
end;

procedure TCEEditorWidget.mnuedSortLinesClick(Sender: TObject);
begin
  if fDoc.isNotNil then
    fDoc.CommandProcessor(ecSortLines, #0, nil);
end;

procedure TCEEditorWidget.mnuedNextCareaClick(Sender: TObject);
begin
  if fDoc.isNotNil then
    fDoc.nextChangedArea;
end;

procedure TCEEditorWidget.mnuedPrevCareaClick(Sender: TObject);
begin
  if fDoc.isNotNil then
    fDoc.previousChangedArea;
end;

procedure TCEEditorWidget.MenuItem8Click(Sender: TObject);
var
  str: TStringList;
begin
  if fDoc.isNil then
    exit;
  if not fDoc.IsDSource and not fDoc.alwaysAdvancedFeatures then
    exit;
  with TSaveDialog.Create(nil) do
  try
    if execute then
    begin
      str := TStringList.Create;
      fTokList.Clear;
      lex(fDoc.Text, fTokList, nil, [lxoNoComments]);
      getImports(fTOkList, str);
      str.SaveToFile(filename);
      fTokList.Clear;
      str.Free;
    end;
  finally
    free;
  end;
end;

procedure TCEEditorWidget.MenuItem6Click(Sender: TObject);
begin
  if fDoc.isNotNil then
    fDoc.CommandProcessor(ecCommentIdentifier, '', nil);
end;

procedure TCEEditorWidget.mnuedRenameClick(Sender: TObject);
begin
  if fDoc.isNotNil then
    fDoc.CommandProcessor(ecRenameIdentifier, '', nil);
end;

procedure TCEEditorWidget.mnuedCutClick(Sender: TObject);
begin
  if fDoc.isNotNil then
    fDoc.ExecuteCommand(ecCut, '', nil);
end;

procedure TCEEditorWidget.mnuedDdocClick(Sender: TObject);
begin
  if fDoc.isNil then exit;
  mnuEditor.Close;
  fDoc.hideCallTips;
  if not fDoc.IsDSource and not fDoc.alwaysAdvancedFeatures then
    exit;
  fDoc.showDDocs;
end;

procedure TCEEditorWidget.mnuedPasteClick(Sender: TObject);
begin
  if fDoc.isNotNil then
    fDoc.ExecuteCommand(ecPaste, '', nil);
end;

procedure TCEEditorWidget.mnuedUndoClick(Sender: TObject);
begin
  if fDoc.isNotNil then
    fDoc.ExecuteCommand(ecUndo, '', nil);
end;

procedure TCEEditorWidget.mnuedRedoClick(Sender: TObject);
begin
  if fDoc.isNotNil then
    fDoc.ExecuteCommand(ecRedo, '', nil);
end;

procedure TCEEditorWidget.mnuedJum2DeclClick(Sender: TObject);
begin
  if fDoc.isNotNil then
    getSymbolLoc;
end;

procedure TCEEditorWidget.mnuEditorPopup(Sender: TObject);
begin
  if fDoc.isNil then exit;
  //
  mnuedCut.Enabled:=fDoc.SelAvail;
  mnuedPaste.Enabled:=fDoc.CanPaste;
  mnuedCopy.Enabled:=fDoc.SelAvail;
  mnuedUndo.Enabled:=fDoc.CanUndo;
  mnuedRedo.Enabled:=fDoc.CanRedo;
  mnuedJum2Decl.Enabled:=fDoc.isDSource;
end;
{$ENDREGION}
end.

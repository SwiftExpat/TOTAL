unit TotalDemo.OTAWizard;

interface

implementation

uses
  // RTL
  System.Classes,
  // ToolsAPI
  ToolsAPI,
  // Vcl
  Vcl.Menus, Vcl.Forms, Vcl.Dialogs,
  // TOTAL
  DW.OTA.Wizard, DW.OTA.IDENotifierOTAWizard, DW.OTA.Helpers, DW.Menus.Helpers, DW.OTA.ProjectManagerMenu, DW.OTA.Notifiers,
  // Demo
  TotalDemo.Consts, TotalDemo.DockWindowForm, TotalDemo.Resources;

type
  TDemoOTAWizard = class;

  TDemoProjectManagerMenuNotifier = class(TProjectManagerMenuNotifier)
  private
    FWizard: TDemoOTAWizard;
  public
    procedure DoAddMenu(const AProject: IOTAProject; const AIdentList: TStrings; const AProjectManagerMenuList: IInterfaceList;
      AIsMultiSelect: Boolean); override;
  public
    constructor Create(const AWizard: TDemoOTAWizard);
  end;

  /// <summary>
  ///  Demo add-in wizard descendant that receives IDE notifications
  /// </summary>
  TDemoOTAWizard = class(TIDENotifierOTAWizard)
  private
    FMenuItem: TMenuItem;
    FPMMenuNotifier: ITOTALNotifier;
    FResources: TResources;
    procedure AddDockWindowMenu;
    procedure AddMenu;
    procedure DemoMenuHandler;
    procedure DockWindowActionHandler(Sender: TObject);
    procedure AddToolbarButtons;
  protected
    class function GetWizardName: string; override;
    class function GetWizardLicense: string; override;
  protected
    procedure ActiveFormChanged; override;
    function GetIDString: string; override;
    function GetName: string; override;
    function GetWizardDescription: string; override;
    procedure IDEStarted; override;
    procedure WizardsCreated; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

const
  cPMMPDemoSection = pmmpVersionControlSection + 100000;
  cTOTALDemoToolbarName = 'TOTALDemoToolbar';
  cTOTALDemoToolbarCaption = 'TOTAL';

{ TDemoProjectManagerMenuNotifier }

constructor TDemoProjectManagerMenuNotifier.Create(const AWizard: TDemoOTAWizard);
begin
  inherited Create;
  FWizard := AWizard;
end;

procedure TDemoProjectManagerMenuNotifier.DoAddMenu(const AProject: IOTAProject; const AIdentList: TStrings;
  const AProjectManagerMenuList: IInterfaceList; AIsMultiSelect: Boolean);
begin
  AProjectManagerMenuList.Add(TProjectManagerMenuSeparator.Create(cPMMPDemoSection));
  AProjectManagerMenuList.Add(TProjectManagerMenu.Create('Demo Item', 'DemoItem', cPMMPDemoSection + 100, FWizard.DemoMenuHandler));
end;

{ TDemoOTAWizard }

constructor TDemoOTAWizard.Create;
begin
  inherited;
  TOTAHelper.RegisterThemeForms([TDockWindowForm]);
  FResources := TResources.Create(Application);
  FPMMenuNotifier := TDemoProjectManagerMenuNotifier.Create(Self);
  (BorlandIDEServices as INTAServices).NewToolbar(cTOTALDemoToolbarName, cTOTALDemoToolbarCaption);
  AddMenu;
  AddDockWindowMenu;
  AddToolbarButtons;
end;

destructor TDemoOTAWizard.Destroy;
begin
  FMenuItem.Free;
  FPMMenuNotifier.RemoveNotifier;
  inherited;
end;

procedure TDemoOTAWizard.AddMenu;
var
  LToolsMenuItem: TMenuItem;
begin
  // Finds the Tools menu in the IDE, and adds its own menu item underneath it
  if TOTAHelper.FindToolsMenu(LToolsMenuItem) then
  begin
    FMenuItem := TMenuItem.Create(nil);
    FMenuItem.Name := cTOTALDemoMenuItemName;
    FMenuItem.Caption := 'TOTAL Demo';
    LToolsMenuItem.Insert(0, FMenuItem);
  end;
end;

procedure TDemoOTAWizard.AddDockWindowMenu;
var
  LMenuItem: TMenuItem;
begin
  LMenuItem := TMenuItem.CreateWithAction(FMenuItem, 'Dock Window', DockWindowActionHandler);
  FMenuItem.Insert(FMenuItem.Count, LMenuItem);
end;

procedure TDemoOTAWizard.AddToolbarButtons;
var
  LServices: INTAServices;
begin
  LServices := BorlandIDEServices as INTAServices;
  if LServices.GetToolbar(cTOTALDemoToolbarName) <> nil then
  begin
    LServices.AddToolButton(cTOTALDemoToolbarName, 'TOTALDemo1Button', FResources.Demo1Action);
    LServices.AddToolButton(cTOTALDemoToolbarName, 'TOTALDemo2Button', FResources.Demo2Action);
  end;
end;

procedure TDemoOTAWizard.DockWindowActionHandler(Sender: TObject);
begin
  if DockWindowForm = nil then
  begin
    DockWindowForm := TDockWindowForm.Create(Application);
    TOTAHelper.ApplyTheme(DockWindowForm);
  end;
  DockWindowForm.Show;
end;

procedure TDemoOTAWizard.DemoMenuHandler;
begin
  ShowMessage('Demo item clicked');
end;

procedure TDemoOTAWizard.IDEStarted;
begin
  inherited;

end;

procedure TDemoOTAWizard.WizardsCreated;
begin
  inherited;

end;

procedure TDemoOTAWizard.ActiveFormChanged;
begin
  inherited;
  
end;

// Unique identifier
function TDemoOTAWizard.GetIDString: string;
begin
  Result := 'com.delphiworlds.totaldemowizard';
end;

function TDemoOTAWizard.GetName: string;
begin
  Result := GetWizardName;
end;

function TDemoOTAWizard.GetWizardDescription: string;
begin
  Result := 'Demo of a Delphi IDE Wizard using TOTAL';
end;

class function TDemoOTAWizard.GetWizardLicense: string;
begin
  Result := 'License for Total Demo';// this can not have line breaks
end;

class function TDemoOTAWizard.GetWizardName: string;
begin
  Result := 'TOTAL Demo';
end;

// Invokes TOTAWizard.InitializeWizard, which in turn creates an instance of the add-in, and registers it with the IDE
function Initialize(const Services: IBorlandIDEServices; RegisterProc: TWizardRegisterProc;
  var TerminateProc: TWizardTerminateProc): Boolean; stdcall;
begin
  Result := TOTAWizard.InitializeWizard(Services, RegisterProc, TerminateProc, TDemoOTAWizard);
end;

exports
  // Provides a function named WizardEntryPoint that is required by the IDE when loading a DLL-based add-in
  Initialize name WizardEntryPoint;

initialization
  // Ensures that the add-in info is displayed on the IDE splash screen and About screen
  TDemoOTAWizard.RegisterSplash;

end.

unit umainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, Menus, ActnList, StdCtrls,TypInfo,Laz2_DOM,XMLPropStorage, XMLConf, StdActns,
  uztoolbarsmanager;

type

  { TForm1 }

  TForm1 = class(TForm)
    ActionList1: TActionList;
    CoolBar1: TCoolBar;
    CoolBar2: TCoolBar;
    CoolBar3: TCoolBar;
    CoolBar4: TCoolBar;
    StatusBar1: TStatusBar;
    FileExit: TFileExit;
    FileOpen: TFileOpen;
    MainMenu1: TMainMenu;
    LoadLayout: TAction;
    SaveLayout: TAction;
    procedure onCreateHandler(Sender: TObject);
    procedure SaveTBLayout(Sender: TObject);
    procedure AsyncLoadTBLayout(Sender: TObject);
  private
    procedure CreateYourOwnTBitem(aNode: TDomNode; TB:TToolBar);
    procedure DoLoadTBLayout(Data: PtrInt);
    procedure LoadTBLayout(Sender: TObject);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.onCreateHandler(Sender: TObject);
begin
  //Setup LCL DragManager
  DragManager.DragImmediate:=false;
  DragManager.DragThreshold:=32;

  //Create ToolBarsManager
  ToolBarsManager:=TToolBarsManager.create(self{mainform},ActionList1{main actionlist},-1{default button height});

  //Register 'Separator' node handler for create toolbar content proc
  ToolBarsManager.RegisterTBItemCreateFunc('Separator',@ToolBarsManager.CreateDefaultSeparator);

  //Register 'Action' node handler for create toolbar content proc
  ToolBarsManager.RegisterTBItemCreateFunc('Action',@ToolBarsManager.CreateDefaultAction);

  //Register 'YourOwnTBitem' node fake handler for create toolbar content proc
  ToolBarsManager.RegisterTBItemCreateFunc('YourOwnTBitem',@CreateYourOwnTBitem);

  //Register 'ToolBar' create proc
  ToolBarsManager.RegisterTBCreateFunc('ToolBar',@ToolBarsManager.CreateDefaultToolBar);

  //Load toolbars content from toolbarscontent.xml
  ToolBarsManager.LoadToolBarsContent('toolbarscontent.xml');

  //Load toolbars layout
  LoadTBLayout(nil);
end;

//Save current toolbars layout
procedure TForm1.SaveTBLayout(Sender: TObject);
var
  XMLConfig: TXMLConfig;
  Config: TXMLConfigStorage;
begin
  XMLConfig:=TXMLConfig.Create(nil);
  try
    XMLConfig.StartEmpty:=true;
    XMLConfig.Filename:='toolbarslayout.xml';
    Config:=TXMLConfigStorage.Create(XMLConfig);
    try
      ToolBarsManager.SaveToolBarsToConfig(self,Config);
    finally
      Config.Free;
    end;
    XMLConfig.Flush;
  finally
    XMLConfig.Free;
  end;
end;

//the load toolbar procedure
procedure TForm1.DoLoadTBLayout(Data: PtrInt);
var
  XMLConfig: TXMLConfigStorage;
begin
    XMLConfig:=TXMLConfigStorage.Create('toolbarslayout.xml',True);
    try
      ToolBarsManager.RestoreToolBarsFromConfig(self,XMLConfig);
    finally
      XMLConfig.Free;
    end;
end;

//async wrapper for load toolbar procedure
//this is necessary because of the of all existing
//toolbars destroy before new loading
//and if call LoadTBLayout by load button clicked - app crashed
//this used in actions
procedure TForm1.AsyncLoadTBLayout(Sender: TObject);
begin
 Application.QueueAsyncCall(@DoLoadTBLayout, 0);
end;

//sync wrapper for load toolbar procedure
//this used in code
procedure TForm1.LoadTBLayout(Sender: TObject);
begin
    DoLoadTBLayout(0);
end;

//'YourOwnTBitem' node fake handler
procedure TForm1.CreateYourOwnTBitem(aNode: TDomNode; TB:TToolBar);
begin
   //you need read aNode params to create your own toolbar item
   //but because of laziness, I'll just create a empty button ))
    with TToolButton.Create(tb) do
    begin
      Caption:='Empty';
      ShowCaption:=true;
      ShowHint:=true;
      Parent:=tb;
      Visible:=true;
    end;
end;

end.

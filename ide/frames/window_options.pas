{
 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.   *
 *                                                                         *
 ***************************************************************************
}
unit window_options;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  // LCL
  Forms, StdCtrls, InterfaceBase,
  // LazControls
  DividerBevel,
  // IdeIntf
  IDEOptionsIntf, IDEOptEditorIntf,
  // IdeConfig
  EnvironmentOpts,
  // IDE
  LazarusIDEStrConsts, EnvGuiOptions;

type
  { TWindowOptionsFrame }

  TWindowOptionsFrame = class(TAbstractIDEOptionsEditor)
    AutoAdjustIDEHeightFullCompPalCheckBox: TCheckBox;
    bvWindowTitle: TDividerBevel;
    EdTitleBar: TComboBox;
    lblTitleBar: TLabel;
    ProjectInspectorShowPropsCheckBox: TCheckBox;
    lblShowingWindows: TDividerBevel;
    NameForDesignedFormListCheckBox: TCheckBox;
    AutoAdjustIDEHeightCheckBox: TCheckBox;
    HideIDEOnRunCheckBox: TCheckBox;
    SingleTaskBarButtonCheckBox: TCheckBox;
    TitleStartsWithProjectCheckBox: TCheckBox;
    TitleShowsProjectDirCheckBox: TCheckBox;
  public
    function GetTitle: String; override;
    procedure Setup({%H-}ADialog: TAbstractOptionsEditorDialog); override;
    procedure ReadSettings(AOptions: TAbstractIDEOptions); override;
    procedure WriteSettings(AOptions: TAbstractIDEOptions); override;
    class function SupportedOptionsClass: TAbstractIDEOptionsClass; override;
  end;

implementation

{$R *.lfm}

{ TWindowOptionsFrame }

function TWindowOptionsFrame.GetTitle: String;
begin
  Result := dlgWindow;
end;

procedure TWindowOptionsFrame.Setup(ADialog: TAbstractOptionsEditorDialog);
begin
  // windows
  lblShowingWindows.Caption := dlgShowingWindows;
  SingleTaskBarButtonCheckBox.Caption := dlgSingleTaskBarButton;
  SingleTaskBarButtonCheckBox.Enabled :=
    WidgetSet.GetLCLCapability(lcNeedMininimizeAppWithMainForm) = LCL_CAPABILITY_YES;
  SingleTaskBarButtonCheckBox.Hint:=lisShowOnlyOneButtonInTheTaskbarForTheWholeIDEInstead;
  HideIDEOnRunCheckBox.Caption := dlgHideIDEOnRun;
  HideIDEOnRunCheckBox.Hint := dlgHideIDEOnRunHint;
  TitleStartsWithProjectCheckBox.Caption:=lisIDETitleStartsWithProjectName;
  TitleStartsWithProjectCheckBox.Hint:=lisTitleInTaskbarShowsForExampleProject1LpiLazarus;
  TitleShowsProjectDirCheckBox.Caption:=lisIDETitleShowsProjectDir;
  TitleShowsProjectDirCheckBox.Hint:=lisProjectDirectoryIsShowedInIdeTitleBar;
  bvWindowTitle.Caption:=lisIDETitleOptions;
  lblTitleBar.Caption:=lisIDETitleCustom;
  EdTitleBar.Hint := lisIDECaptionCustomHint;
  NameForDesignedFormListCheckBox.Caption:=lisWindowMenuWithNameForDesignedForm;
  NameForDesignedFormListCheckBox.Hint:=lisWindowMenuWithNameForDesignedFormHint;
  AutoAdjustIDEHeightCheckBox.Caption:=lisAutoAdjustIDEHeight;
  AutoAdjustIDEHeightCheckBox.Hint:=lisAutoAdjustIDEHeightHint;
  AutoAdjustIDEHeightFullCompPalCheckBox.Caption:=lisAutoAdjustIDEHeightFullComponentPalette;
  AutoAdjustIDEHeightFullCompPalCheckBox.Hint:=lisAutoAdjustIDEHeightFullComponentPaletteHint;
  ProjectInspectorShowPropsCheckBox.Caption:=lisProjectInspectorShowProps;

  EdTitleBar.AddItem('$project(TitleNew)', nil);
  EdTitleBar.AddItem('$project(TitleNew) $EncloseBracket($project(infodir))', nil);
  EdTitleBar.AddItem('$(BuildModeCaption)', nil);
  EdTitleBar.AddItem('$project(TitleNew) $EncloseBracket($project(infodir)) $(BuildModeCaption)', nil);
  EdTitleBar.AddItem('$(FPCTarget)', nil);
  EdTitleBar.AddItem('$TargetCPU(Param)-$TargetOS(Param)-$SubTarget(Param)', nil);
  EdTitleBar.AddItem('$(LCLWidgetType)', nil);
  EdTitleBar.AddItem('$(FPCVer)', nil);
  EdTitleBar.AddItem('$project(TitleNew) $EncloseBracket($project(infodir)) $(BuildModeCaption) $(LCLWidgetType) $(FPCTarget)', nil);
  EdTitleBar.AddItem('$(EdFile)', nil);
end;

procedure TWindowOptionsFrame.ReadSettings(AOptions: TAbstractIDEOptions);
var
  EnvOpt: TEnvironmentOptions;
  EnvGui: TIDESubOptions;
begin
  EnvOpt := AOptions as TEnvironmentOptions;
  EnvGui := EnvOpt.GetSubConfigObj(TEnvGuiOptions);
  with (EnvGui as TEnvGuiOptions).Desktop do
  begin
    // window minimizing and hiding
    SingleTaskBarButtonCheckBox.Checked := SingleTaskBarButton;
    HideIDEOnRunCheckBox.Checked := HideIDEOnRun;
    TitleStartsWithProjectCheckBox.Checked := IDETitleStartsWithProject;
    TitleShowsProjectDirCheckBox.Checked := IDETitleShowsProjectDir;
    EdTitleBar.Text := IDETitleBarCustomText;
    NameForDesignedFormListCheckBox.Checked := IDENameForDesignedFormList;
    AutoAdjustIDEHeightCheckBox.Checked := AutoAdjustIDEHeight;
    AutoAdjustIDEHeightFullCompPalCheckBox.Checked := AutoAdjustIDEHeightFullCompPal;
    ProjectInspectorShowPropsCheckBox.Checked := ProjectInspectorShowProps;
  end;
end;

procedure TWindowOptionsFrame.WriteSettings(AOptions: TAbstractIDEOptions);
var
  EnvOpt: TEnvironmentOptions;
  EnvGui: TIDESubOptions;
begin
  EnvOpt := AOptions as TEnvironmentOptions;
  EnvGui := EnvOpt.GetSubConfigObj(TEnvGuiOptions);
  with (EnvGui as TEnvGuiOptions).Desktop do
  begin
    // window minimizing
    SingleTaskBarButton := SingleTaskBarButtonCheckBox.Checked;
    HideIDEOnRun := HideIDEOnRunCheckBox.Checked;
    IDETitleStartsWithProject := TitleStartsWithProjectCheckBox.Checked;
    IDETitleShowsProjectDir := TitleShowsProjectDirCheckBox.Checked;
    IDETitleBarCustomText := EdTitleBar.Text;
    IDENameForDesignedFormList := NameForDesignedFormListCheckBox.Checked;
    AutoAdjustIDEHeight := AutoAdjustIDEHeightCheckBox.Checked;
    AutoAdjustIDEHeightFullCompPal := AutoAdjustIDEHeightFullCompPalCheckBox.Checked;
    ProjectInspectorShowProps := ProjectInspectorShowPropsCheckBox.Checked;
  end;
end;

class function TWindowOptionsFrame.SupportedOptionsClass: TAbstractIDEOptionsClass;
begin
  Result := TEnvironmentOptions;
end;

initialization
  RegisterIDEOptionsEditor(GroupEnvironment, TWindowOptionsFrame, EnvOptionsWindow);
end.


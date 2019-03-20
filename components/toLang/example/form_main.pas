unit form_Main;

{$mode objfpc}

interface

uses Interfaces, Forms, StdCtrls, Classes, SysUtils, FileUtil,
  gvars, toLang;

type
  Tform_main = class(TForm)
    {Form Creation}
    constructor Create({!}AOwner: TComponent); override;
    {Form Controls}
  var //fields can't appear after method, let's use vars instead
    MyButton: TButton;

    {Form Actions}
    procedure CloseMainForm(ASender: TObject);
  end;


implementation

{Form Creation}
constructor Tform_main.Create(AOwner: TComponent);
begin

  {!}inherited CreateNew(AOwner, 1);{!}
  Caption := toLangInst1.Get('AppName');
  Position := poScreenCenter;
  Height := 100;
  Width := 300;
  VertScrollBar.Visible := False;
  HorzScrollBar.Visible := False;
  {Form Controls}
  MyButton := TButton.Create(Self);
  with MyButton do
  begin
    Height := 30;
    Left := 100;
    Top := 32;
    Width := 100;
    Caption := toLangInst2.Get('Close');
    {MyButton.}OnClick := @CloseMainForm;
    Parent := Self;
  end;
end;

{Form Actions}
procedure Tform_main.CloseMainForm(ASender: TObject);
begin
  ASender := ASender;//to get rid of Hint: Parameter "ASender" not used
  Close;
end;




end.

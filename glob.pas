unit glob;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, StdCtrls,
  form_1,
  toLang, toStringObj;//in components/toLang

type
  T_toLang = TtoLang; //get toLang object avialable in gvars

const
  path_media = 'media';
  path_media_s = path_media + DirectorySeparator;
  Memo_dbgMaxLines = 30;

var
  msg: TtoLang;
  appname: string;
  Form1: TForm1;
  wine, spinEdLoop: boolean;
  UpdateInterval:integer;
  val:toStringObj.Type_toStringObj;



procedure toMemo(str: string = ''; target: TMemo = nil);

implementation

procedure toMemo(str: string = ''; target: TMemo = nil);
begin
  if str = '' then
    exit;
  if target = nil then
    target := Form1.Memo_dbg;
  if target.Lines.Capacity = Memo_dbgMaxLines then begin
    target.Lines.Clear;
    target.VertScrollBar.Position:=0;
  end;
  target.Lines.Add(str);
  //sroll down
  target.VertScrollBar.Position :=
    target.Lines.Capacity * target.VertScrollBar.Page;
end;

initialization
  appname := Application.Title;
  UpdateInterval := 20;
  val:=toStringObj.Type_toStringObj.Create;
  {$IFDEF Windows}
  if FileExists(SysUtils.GetEnvironmentVariable('windir') + '\system32\winecfg.exe') then
    wine := True//Writeln ('wine detected');
{$DEFINE wine}
  ;
{$ELSE}
  wine := False;
{$ENDIF}
  spinEdLoop := False;




end.

unit gvars;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms,
  form_1,
  toLang;//in components/toLang

type
  T_toLang = TtoLang; //get toLang object avialable in gvars

const
  path_media = 'media';
  path_media_s = path_media + DirectorySeparator;

var
  msg: TtoLang;
  appname: string;
  form1: Tform_1;
  wine,spinEdLoop:boolean;

implementation

initialization
  appname := Application.Title;
  {$IFDEF Windows}
  If FileExists(SysUtils.GetEnvironmentVariable('windir')+'\system32\winecfg.exe')
  Then begin
    //Writeln ('wine detected');
    wine:=True;
    {$DEFINE wine}
  end;
{$ELSE}
  wine:=False;
{$ENDIF}
spinEdLoop:=False;

end.

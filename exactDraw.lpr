program testcanvas2Dresourceless;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  bgracontrols,
  bgrabitmappack,
  SysUtils,
  form_1,
  glob,
  toLang_defaults;

//{$R *.res}

begin
  //load default msgs from laz_unitz/toLang/toLang_defaults.pas
  glob.msg := glob.T_toLang.Create();
  //or load messages from ini file
  //gvars.msg := gvars.T_toLang..Create('lang/Russian');
  RequireDerivedFormResource := False;
  {app taskbar icon}
  //set by project options
  Application.Title := 'exactDraw.unix.x86_64';
  Application.Icon.LoadFromFile(glob.path_media_s + 'MyIcon.ico');
  {end app taskbar icon}
  Application.Initialize;
  Application.CreateForm(TForm1, glob.Form1);
  Application.Run;
end.

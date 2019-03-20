program gui_resourceless;

{$ifdef WIN32}
  {$APPTYPE GUI}
{$ENDIF}
{$mode objfpc}

uses
  Interfaces,
  Forms,
  gvars,
  form_Main, toLang_defaults, toLang;

var
  f_main: Tform_main;

begin

  RequireDerivedFormResource := False;

  gvars.toLangInst1 := tlang.Create();//test defaults
  gvars.toLangInst2 := tlang.Create('lang/Russian');// test loading from ini file
  writeln('toLangInst1.Get("AppName"): ', toLangInst1.Get('AppName'));
  writeln('toLangInst2.Get("AppName"): ', toLangInst2.Get('AppName'));
  writeln('toLangInst1.Get("Close"): ', toLangInst1.Get('Close'));
  writeln('toLangInst2.Get("Close"): ', toLangInst2.Get('Close'));




  Application.Initialize;

  Application.CreateForm(Tform_main, f_main);


  Application.Run;

end.

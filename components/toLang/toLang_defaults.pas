unit toLang_defaults;

{$mode objfpc}

interface

procedure createDefaults(objinst: TObject);

implementation

uses toLang;

procedure createDefaults(objinst: TObject);
begin
  TtoLang(objinst).Add('PixCentCoord', 'Pixel-centered coordinates');
  TtoLang(objinst).Add('toDataURL', '');
  TtoLang(objinst).Add('antialias', 'Antialiasing');
  TtoLang(objinst).Add('HTML file (*.html);*.html', 'Save as HTML file...');
  TtoLang(objinst).Add('DlgSave_toDataURL', 'toDataURL');
  TtoLang(objinst).Add('DlgSave_Out', 'Output: ');
  TtoLang(objinst).Add('Memo_dbg_caption', 'Debug output');
  TtoLang(objinst).Add('antialias', 'Antialiasing');
  TtoLang(objinst).Add('antialias', 'Antialiasing');
end;

end.

unit toLang;

{$mode objfpc}

interface

uses
  Classes, SysUtils, IniFiles, toLang_defaults;

type
  TtoLang = class
  private
    type TStrN = string[32];
    type TStrM = ansistring;
  var
    ArrKeys: array of TStrN;
  var
    ArrMessages: array of TStrM;
  const
    created: boolean = False;

    function fromFile(fn: string): boolean;
  public
    constructor Create(target: string = ''); overload;
    function Get(Name: TStrN): TStrM;
    procedure Add(Name: TStrN; message: TStrM);
    procedure setMessages(target:string='');
  end;

implementation

function TtoLang.Get(Name: TStrN): TStrM;
var
  key: integer;
  found: boolean;
begin
  if not self.created then
    exit('');
  Result := '';
  found := False;
  key := 0;
  Name := LowerCase(Name);
  while key <= high(self.ArrKeys) do
  begin
    if ArrKeys[key] = Name then
    begin
      found := True;
      Break;
    end;
    key := key + 1;
  end; //while key <= high(self.ArrKeys)

  if found then
  begin
    if high(ArrMessages) >= key then
    begin
      if ArrMessages[key] <> '' then
        exit(ArrMessages[key])
      else
        exit(ArrKeys[key]);
    end;
  end//ArrKeys[key] = Name
  else
    exit('');

end;

procedure TtoLang.Add(Name: TStrN; message: TStrM);
var
  key: integer;
begin

  if not self.created then
    exit;
  key := 0;
  Name := LowerCase(Name);
  //if exists then nothing to do
  self.Get(Name);
  if self.Get(Name) <> '' then
    exit;
  SetLength(self.ArrKeys, Length(self.ArrKeys) + 1);
  SetLength(self.ArrMessages, Length(self.ArrKeys) + 1);
  key := high(self.ArrKeys);
  self.ArrKeys[key] := Name;
  self.ArrMessages[key] := message;
end;

function TtoLang.fromFile(fn: string): boolean;
var
  section, iniKey: string;
  INI_obj: TINIFile;
  Messages: TStringList;
  key: integer;
begin
  if not self.created then
    exit(False);
  if not FileExists(fn) then
  begin
    exit(False);
  end;
  INI_obj := TINIFile.Create(fn);
  Messages := TStringList.Create;
  section := 'Messages';
  try
    INI_obj.ReadSection(section, Messages);
    key := 0;
    if Messages.Count = 0 then
      exit(False);
    while key < Messages.Count do
    begin
      iniKey := Messages[key];
      self.Add(iniKey, INI_obj.ReadString(section, iniKey, ''));
      key := key + 1;
    end;
  finally
    INI_obj.Free;
    Messages.Free;
  end;
  exit(True);
end;

procedure TtoLang.setMessages(target:string='');
begin
  if not self.created then
    exit;
  if target = '' then
  begin //add defaults
    toLang_defaults.createDefaults(self);
  end
  else
  begin
    target:=SetDirSeparators(target);
    if not self.fromFile(target + '.ini') then
      toLang_defaults.createDefaults(self);
  end;
end;

constructor TtoLang.Create(target: string = '');
begin
  inherited Create();
  SetLength(self.ArrKeys, 0);
  SetLength(self.ArrMessages, 0);
  self.created := True;
  self.setMessages(target);
end;


initialization

end.

unit toStringObj;

{$mode objfpc}

interface

uses
  classes, sysutils,
  Forms{TCloseAction},LCLType{HWND}, BGRABitmapTypes{TPointF};

type Type_toStringObj = class

public
function ts(inVar: Integer): string;
function ts(inVar: Boolean): string;overload;
function ts(inVar: TCloseAction): string;overload;
function ts(inVar: HWND): string;overload;
function ts(inVar: Pointer): string;overload;
function ts(inVar: Int64): string;overload;
function ts(inVar: TDate): string;overload;
function ts(inVar: TPointF): string;overload;
function ts(inVar: Single): string;overload;
end;



implementation


function Type_toStringObj.ts(inVar: Integer): string;
begin exit(intToStr(inVar)); end;

function Type_toStringObj.ts(inVar: Boolean): string;overload;
begin exit(BoolToStr(inVar, True)); end;

function Type_toStringObj.ts(inVar: TCloseAction): string;overload;
begin exit(IntToStr(Qword(inVar))); end;

function Type_toStringObj.ts(inVar: HWND): string;overload;
begin exit(IntToStr(Word(inVar))); end;

function Type_toStringObj.ts(inVar: Pointer): string;overload;
begin exit(Format('%p', [inVar])+'.'); end;

function Type_toStringObj.ts(inVar: Int64): string;overload;
begin exit(IntToStr(inVar)); end;

function Type_toStringObj.ts(inVar: TDate): string;overload;
begin exit(DateToStr(inVar)); end;

function Type_toStringObj.ts(inVar: TPointF): string;overload;
begin exit('('+FloatToStr(inVar.x)+'; ' + FloatToStr(inVar.y)+')'); end;

function Type_toStringObj.ts(inVar: Single): string;overload;
begin exit(FloatToStr(inVar) ); end;


end.

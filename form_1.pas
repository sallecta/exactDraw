unit form_1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Spin,
  ExtCtrls, StdCtrls, BGRAVirtualScreen, BGRABitmap, BGRABitmapTypes,
  BGRACanvas2d;

const
  timeGrain = 15 / 1000 / 60 / 60 / 24;

type

  { TForm1 }

  TForm1 = class(TForm)
    constructor Create({!}AOwner: TComponent); override;
  var //fields can't appear after method, let's use vars instead
    Btn_toDataURL: TButton;
    ChBx_Antialias: TCheckBox;
    ChBox_pixCentered: TCheckBox;
    Pnl_1: TPanel;
    DlgSave_1: TSaveDialog;
    SpinEd1: TSpinEdit;
    VirtScreen: TBGRAVirtualScreen;
    Memo_dbg: TMemo;
    Tmr_1: TTimer;

    procedure Btn_toDataURLClick(Sender: TObject);
    procedure ChBx_AntialiasChange(Sender: TObject);
    procedure ChBox_pixCenteredChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    //procedure FormPaint(Sender: TObject);
    procedure SpinEd1_onChange(Sender: TObject);
    procedure Tmr_1Timer(Sender: TObject);
    procedure VirtScreenMouseLeave(Sender: TObject);
    procedure VirtScreenMouseMove(Sender: TObject; {%H-}Shift: TShiftState;
      X, Y: integer);
    procedure VirtScreenRedraw(Sender: TObject; Bitmap: TBGRABitmap);
  private
    { private declarations }
    CurPoint: integer;
    B1, B2: TRationalQuadraticBezierCurve;
    mx, my: integer;
    lastTime: TDateTime;
    timeGrainAcc: double;
    test4pos, test5pos, Test13pos, test16pos, test17pos, test18pos,
    test19pos, test23pos: integer;
    img, abelias: TBGRABitmap;
    procedure UpdateIn(ms: integer);
    procedure UseVectorizedFont(targetCanvas: TBGRACanvas2D; AUse: boolean);
    {Form Events}
    procedure VirtScreen_OnMouseDown(Sender: TObject; mouseBtn: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure VirtScreen_OnMouseUp(Sender: TObject; mouseBtn: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    {end Form Events}
  public
    { public declarations }
    procedure Test1(targetCanvas: TBGRACanvas2D);
    procedure Test2(targetCanvas: TBGRACanvas2D);
    procedure Test3(targetCanvas: TBGRACanvas2D);
    procedure Test4(targetCanvas: TBGRACanvas2D; grainElapse: integer);
    procedure Test5(targetCanvas: TBGRACanvas2D; grainElapse: integer);
    procedure Test6(targetCanvas: TBGRACanvas2D);
    procedure Test7(targetCanvas: TBGRACanvas2D);
    procedure Test8(targetCanvas: TBGRACanvas2D);
    procedure Test9(targetCanvas: TBGRACanvas2D);
    procedure Test10(targetCanvas: TBGRACanvas2D);
    procedure Test11(targetCanvas: TBGRACanvas2D);
    procedure Test12(targetCanvas: TBGRACanvas2D);
    procedure Test13(targetCanvas: TBGRACanvas2D);
    procedure Test14(targetCanvas: TBGRACanvas2D);
    procedure Test15(targetCanvas: TBGRACanvas2D);
    procedure Test16(targetCanvas: TBGRACanvas2D; grainElapse: integer);
    procedure Test17(targetCanvas: TBGRACanvas2D; grainElapse: integer);
    procedure Test18(targetCanvas: TBGRACanvas2D; grainElapse: integer);
    procedure Test19(targetCanvas: TBGRACanvas2D; grainElapse: integer);
    procedure Test20(targetCanvas: TBGRACanvas2D; AVectorizedFont: boolean);
    procedure Test22(targetCanvas: TBGRACanvas2D);
    procedure Test23(targetCanvas: TBGRACanvas2D; grainElapse: integer);
    procedure Test24(targetCanvas: TBGRACanvas2D);
  end;

var

  {test24 vars srart (rationalbezier)}
  counter1:integer=1;
  mouseBtnCurrent: string[7]='';
  R, bounds: TrectF;
  Aleft, Aright: TRationalQuadraticBezierCurve;
  precision: single;
  weight: single;
  CenterOfDrawing: TPoint;
  minimalDistance: single;
  relX, relY: integer;
  PrevMousePos: TPoint;
  d: TPointF;
  beziersDefined: boolean = False;
  ControlCircleRadius: integer = 5;
  ControlDetected: string[10] = '';
{end test 24 vars (rationalbezier)}

implementation

uses BGRAGradientScanner, Math, BGRASVG, BGRAVectorize,
  glob;

//{$R form_1.lfm}

{ TForm1 }
{resourceless form}
constructor TForm1.Create(AOwner: TComponent);
begin

  {!}inherited CreateNew(AOwner, 1);{!}
  Caption := glob.appname;
  Left := 567;
  Top := 83;
  Width := 720;
  Height := 600;
  ClientWidth := Width;
  ClientHeight := Height;
  OnDestroy := @FormDestroy;
  img := TBGRABitmap.Create(glob.path_media_s + 'pteRaz.jpg');
  abelias := TBGRABitmap.Create(glob.path_media_s + 'abelias.png');
  mx := -1000;
  my := -1000;
  lastTime := Now;
  CurPoint := -1;

  {Form Controls}
  Pnl_1 := TPanel.Create(Self);
  Pnl_1.AutoSize := False;
  Pnl_1.Height := 48;
  Pnl_1.Left := 0;
  Pnl_1.Top := 0;
  Pnl_1.Align := alTop;
  Pnl_1.TabOrder := 1;
  Pnl_1.Parent := self;  //self is instance of TForm1

  SpinEd1 := TSpinEdit.Create(Pnl_1);
  SpinEd1.AutoSize := True;
  SpinEd1.AnchorSideLeft.Control := Pnl_1;
  SpinEd1.AnchorSideTop.Control := Pnl_1;
  SpinEd1.AnchorSideBottom.Control := Pnl_1;
  SpinEd1.AnchorSideBottom.Side := asrBottom;
  SpinEd1.Anchors := [akTop, akLeft, akBottom];
  SpinEd1.BorderSpacing.Left := 8;
  SpinEd1.BorderSpacing.Top := 8;
  SpinEd1.BorderSpacing.Right := 8;
  SpinEd1.BorderSpacing.Bottom := 8;
  SpinEd1.Increment := 1;
  SpinEd1.MaxValue := 24 + SpinEd1.Increment;//provides loop to beginning
  SpinEd1.MinValue := 1 - SpinEd1.Increment;//provides loop to end
  SpinEd1.TabOrder := 0;
  SpinEd1.Value := 24;
  if glob.wine then
    SpinEd1.Font.Size := 14;
  SpinEd1.AutoSelect := False;
  SpinEd1.OnChange := @SpinEd1_onChange;
  SpinEd1.Parent := Pnl_1;

  ChBox_pixCentered := TCheckBox.Create(Pnl_1);
  ChBox_pixCentered.AutoSize := True;
  ChBox_pixCentered.AnchorSideLeft.Control := SpinEd1;
  ChBox_pixCentered.AnchorSideLeft.Side := asrBottom;
  ChBox_pixCentered.AnchorSideTop.Control := Pnl_1;
  ChBox_pixCentered.AnchorSideTop.Side := asrCenter;
  ChBox_pixCentered.AnchorSideBottom.Control := Pnl_1;
  ChBox_pixCentered.AnchorSideBottom.Side := asrBottom;
  ChBox_pixCentered.Anchors := [akTop, akLeft, akBottom];
  ChBox_pixCentered.BorderSpacing.Left := 8;
  ChBox_pixCentered.BorderSpacing.Top := 8;
  ChBox_pixCentered.BorderSpacing.Bottom := 8;
  ChBox_pixCentered.Caption := glob.msg.Get('PixCentCoord');
  ChBox_pixCentered.Font.Height := -12;
  ChBox_pixCentered.ParentFont := False;
  ChBox_pixCentered.OnChange := @ChBox_pixCenteredChange;
  ChBox_pixCentered.TabOrder := 1;
  ChBox_pixCentered.Parent := Pnl_1;

  Btn_toDataURL := TButton.Create(Pnl_1);
  Btn_toDataURL.AutoSize := True;
  Btn_toDataURL.AnchorSideLeft.Control := ChBox_pixCentered;
  Btn_toDataURL.AnchorSideLeft.Side := asrBottom;
  Btn_toDataURL.AnchorSideTop.Control := Pnl_1;
  Btn_toDataURL.AnchorSideTop.Side := asrCenter;
  Btn_toDataURL.AnchorSideBottom.Control := Pnl_1;
  Btn_toDataURL.AnchorSideBottom.Side := asrBottom;
  Btn_toDataURL.Anchors := [akTop, akLeft, akBottom];
  Btn_toDataURL.BorderSpacing.Left := 8;
  Btn_toDataURL.BorderSpacing.Top := 8;
  Btn_toDataURL.BorderSpacing.Bottom := 8;
  Btn_toDataURL.Caption := glob.msg.Get('toDataURL');
  Btn_toDataURL.OnClick := @Btn_toDataURLClick;
  Btn_toDataURL.TabOrder := 2;
  Btn_toDataURL.Parent := Pnl_1;

  ChBx_Antialias := TCheckBox.Create(Pnl_1);
  ChBx_Antialias.AutoSize := True;
  ChBx_Antialias.AnchorSideLeft.Control := Btn_toDataURL;
  ChBx_Antialias.AnchorSideLeft.Side := asrBottom;
  ChBx_Antialias.AnchorSideTop.Control := Pnl_1;
  ChBx_Antialias.AnchorSideTop.Side := asrCenter;
  ChBx_Antialias.AnchorSideBottom.Control := Pnl_1;
  ChBx_Antialias.AnchorSideBottom.Side := asrBottom;
  ChBx_Antialias.Anchors := [akTop, akLeft, akBottom];
  ChBx_Antialias.BorderSpacing.Left := 8;
  ChBx_Antialias.BorderSpacing.Top := 8;
  ChBx_Antialias.BorderSpacing.Bottom := 8;
  ChBx_Antialias.Caption := glob.msg.Get('antialias');
  ChBx_Antialias.Checked := True;
  ChBx_Antialias.OnChange := @ChBx_AntialiasChange;
  ChBx_Antialias.State := cbChecked;
  ChBx_Antialias.TabOrder := 3;
  ChBx_Antialias.Parent := Pnl_1;

  Tmr_1 := TTimer.Create(self);//self is instance of TForm1           ;
  Tmr_1.OnTimer := @Tmr_1Timer;

  DlgSave_1 := TSaveDialog.Create(self);//self is instance of TForm1        ;
  DlgSave_1.Title := glob.msg.Get('saveAsHtm');
  DlgSave_1.DefaultExt := '.html';
  DlgSave_1.Filter := glob.msg.Get('HtmFile');

  Memo_dbg := TMemo.Create(self);
  Memo_dbg.AnchorSideLeft.Control := self;  //self is instance of TForm1
  Memo_dbg.AnchorSideTop.Control := VirtScreen;
  Memo_dbg.AnchorSideTop.Side := asrBottom;
  Memo_dbg.AnchorSideRight.Control := self;  //self is instance of TForm1
  Memo_dbg.AnchorSideRight.Side := asrBottom;
  Memo_dbg.AnchorSideBottom.Control := self;  //self is instance of TForm1
  Memo_dbg.AnchorSideBottom.Side := asrBottom;
  Memo_dbg.Anchors := [akLeft, akRight, akBottom];
  Memo_dbg.Lines.Add(glob.msg.Get('Memo_dbg_caption'));
  Memo_dbg.Height := 80;
  Memo_dbg.ScrollBars := ssBoth;
  Memo_dbg.Parent := self;  //self is instance of TForm1

  VirtScreen := TBGRAVirtualScreen.Create(Self);
  VirtScreen.AutoSize := True;
  VirtScreen.AnchorSideLeft.Control := self;//self is instance of TForm1
  VirtScreen.AnchorSideTop.Control := Pnl_1;
  VirtScreen.AnchorSideTop.Side := asrBottom;
  VirtScreen.AnchorSideRight.Control := self;//self is instance of TForm1
  VirtScreen.AnchorSideRight.Side := asrBottom;
  VirtScreen.AnchorSideBottom.Control := Memo_dbg;//self is instance of TForm1
  VirtScreen.AnchorSideBottom.Side := asrTop;
  VirtScreen.Anchors := [akTop, akLeft, akRight, akBottom];
  VirtScreen.ParentColor := False;
  VirtScreen.TabOrder := 0;
  VirtScreen.OnRedraw := @VirtScreenRedraw;
  VirtScreen.OnMouseLeave := @VirtScreenMouseLeave;
  VirtScreen.OnMouseMove := @VirtScreenMouseMove;
  VirtScreen.OnMouseDown := @VirtScreen_OnMouseDown;
  VirtScreen.OnMouseUp := @VirtScreen_OnMouseUp;
  VirtScreen.Parent := self;  //self is instance of TForm1

end;

{end resourceless form}

{Form Events}

{end Form Events}


procedure TForm1.FormCreate(Sender: TObject);
begin
  img := TBGRABitmap.Create(glob.path_media_s + 'pteRaz.jpg');
  abelias := TBGRABitmap.Create(glob.path_media_s + 'abelias.png');
  mx := -1000;
  my := -1000;
  lastTime := Now;
end;

procedure TForm1.ChBox_pixCenteredChange(Sender: TObject);
begin
  VirtScreen.DiscardBitmap;
end;

procedure TForm1.Btn_toDataURLClick(Sender: TObject);
var
  html: string;
  t: textfile;
begin
  if DlgSave_1.Execute then
  begin
    html := '<html><body><img src="';
    html += VirtScreen.Bitmap.Canvas2D.toDataURL;
    html += '"/></body></html>';
    assignfile(t, DlgSave_1.FileName);
    rewrite(t);
    Write(t, html);
    closefile(t);
    MessageDlg(glob.msg.Get('DlgSave_toDataURL'), glob.msg.Get('DlgSave_Out') +
      DlgSave_1.FileName, mtInformation, [mbOK], 0);
  end;
end;

procedure TForm1.ChBx_AntialiasChange(Sender: TObject);
begin
  VirtScreen.DiscardBitmap;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  img.Free;
  abelias.Free;
end;



procedure TForm1.SpinEd1_onChange(Sender: TObject);
begin
  //spin edit loop from min value + increment to max value - increment
  if glob.Form1.SpinEd1.Value = glob.Form1.SpinEd1.MaxValue then
    glob.Form1.SpinEd1.Value :=
      glob.Form1.SpinEd1.MinValue + glob.Form1.SpinEd1.Increment
  else if glob.Form1.SpinEd1.Value = glob.Form1.SpinEd1.MinValue then
    glob.Form1.SpinEd1.Value :=
      glob.Form1.SpinEd1.MaxValue - glob.Form1.SpinEd1.Increment
  else
    VirtScreen.DiscardBitmap;
end;

procedure TForm1.Tmr_1Timer(Sender: TObject);
begin
  Tmr_1.Enabled := False;
  VirtScreen.DiscardBitmap;
end;

procedure TForm1.VirtScreenMouseLeave(Sender: TObject);
begin
  mx := -1000;
  my := -1000;
end;

procedure TForm1.VirtScreenMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  mx := X;
  my := Y;
  if (SpinEd1.Value = 1) and not Tmr_1.Enabled then
    UpdateIn(10);
end;

procedure TForm1.VirtScreen_OnMouseDown(Sender: TObject; mouseBtn: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  X:=X;Y:=Y;Shift:=Shift;
  case mouseBtn of
    TMouseButton.mbLeft: mouseBtnCurrent := 'left';
    else
      mouseBtnCurrent := '';
  end;
end;

procedure TForm1.VirtScreen_OnMouseUp(Sender: TObject; mouseBtn: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  X:=X;Y:=Y;Shift:=Shift;mouseBtn:=mouseBtn;
  mouseBtnCurrent := '';
end;

procedure TForm1.VirtScreenRedraw(Sender: TObject; Bitmap: TBGRABitmap);
var
  targetCanvas: TBGRACanvas2D;
  grainElapse: integer;
  newTime: TDateTime;
begin
  newTime := Now;
  timeGrainAcc += (newTime - lastTime) / timeGrain;
  lastTime := newTime;
  if timeGrainAcc < 1 then
    timeGrainAcc := 1;
  if timeGrainAcc > 50 then
    timeGrainAcc := 50;
  grainElapse := trunc(timeGrainAcc);
  timeGrainAcc -= grainElapse;

  targetCanvas := Bitmap.Canvas2D;
  targetCanvas.antialiasing := ChBx_Antialias.Checked;
  targetCanvas.pixelCenteredCoordinates := ChBox_pixCentered.Checked;
  targetCanvas.save;

  case SpinEd1.Value of
    1: Test1(targetCanvas);
    2: Test2(targetCanvas);
    3: Test3(targetCanvas);
    4: Test4(targetCanvas, grainElapse);
    5: Test5(targetCanvas, grainElapse);
    6: Test6(targetCanvas);
    7: Test7(targetCanvas);
    8: Test8(targetCanvas);
    9: Test9(targetCanvas);
    10: Test10(targetCanvas);
    11: Test11(targetCanvas);
    12: Test12(targetCanvas);
    13: Test13(targetCanvas);
    14: Test14(targetCanvas);
    15: Test15(targetCanvas);
    16: Test16(targetCanvas, grainElapse);
    17: Test17(targetCanvas, grainElapse);
    18: Test18(targetCanvas, grainElapse);
    19: Test19(targetCanvas, grainElapse);
    20: Test20(targetCanvas, False);
    21: Test20(targetCanvas, True);
    22: Test22(targetCanvas);
    23: Test23(targetCanvas, grainElapse);
    24: Test24(targetCanvas);
  end;
  targetCanvas.restore;
end;

procedure TForm1.UpdateIn(ms: integer);
begin
  Tmr_1.Interval := ms;
  Tmr_1.Enabled := False;
  Tmr_1.Enabled := True;
end;

procedure TForm1.UseVectorizedFont(targetCanvas: TBGRACanvas2D; AUse: boolean);
begin
  if AUse and not (targetCanvas.fontRenderer is TBGRAVectorizedFontRenderer) then
    targetCanvas.fontRenderer := TBGRAVectorizedFontRenderer.Create;
  if not AUse and (targetCanvas.fontRenderer is TBGRAVectorizedFontRenderer) then
    targetCanvas.fontRenderer := nil;
end;

procedure TForm1.Test1(targetCanvas: TBGRACanvas2D);
var
  colors: TBGRACustomGradient;
begin
  if (mx < 0) or (my < 0) then
  begin
    mx := targetCanvas.Width div 2;
    my := targetCanvas.Height div 2;
  end;
  targetCanvas.fillStyle('rgb(1000,1000,1000)');
  //out of bounds so it is saturated to 255,255,255
  targetCanvas.fillRect(0, 0, targetCanvas.Width, targetCanvas.Height);
  colors := TBGRAMultiGradient.Create([BGRA(0, 255, 0), BGRA(0, 192, 128),
    BGRA(0, 255, 0)], [0, 0.5, 1], True, True);
  targetCanvas.fillStyle(targetCanvas.createLinearGradient(0, 0, 20, 0, colors));
  targetCanvas.shadowOffset := PointF(5, 5);
  targetCanvas.shadowColor('rgba(0,0,0,0.5)');
  targetCanvas.shadowBlur := 4;
  targetCanvas.fillRect(mx - 100, my - 100, 200, 200);
  colors.Free;
end;

procedure TForm1.Test2(targetCanvas: TBGRACanvas2D);
var
  layer: TBGRABitmap;
begin
  layer := TBGRABitmap.Create(targetCanvas.Width, targetCanvas.Height);
  with layer.Canvas2D do
  begin
    pixelCenteredCoordinates := targetCanvas.pixelCenteredCoordinates;
    antialiasing := targetCanvas.antialiasing;

    begin//parent red round rectangle
      fillStyle('rgb(255,0,132)');
      beginPath;
      roundRect(25, 25, Width - 50, Height - 50, 25);
      fill;
    end;

    begin  // dynamic small square
      beginPath;
      rect(Width - mx - 25, Height - my - 25, 77, 77);
      fillStyle('rgb(132,184,132)');
      fill;
    end;

    begin //static small arc
      beginPath;
      arc(500, 50, 30, 0, 3);
      fillStyle('rgb(201,168,255)');
      fill;
    end;

    begin //dynamic small circle
      beginPath;
      //arc(mx, my, 30, 0, 2 * Pi);
      circle(mx, my, 30);
      fillStyle('rgb(201,168,255)');
      fill;
    end;

    begin //yellow rectangle with blur
      beginPath;
      strokeStyle('rgb(255,255,0)');
      linewidth := 2;
      shadowOffset := PointF(3, 3);
      shadowColor('rgba(0,0,0,0.5)');
      shadowBlur := 4;
      strokeRect(100, 100, 70, 30);
    end;

    begin //line 1
      beginPath;
      lineWidth := 4;
      moveTo(20, 160);
      lineTo(200, 160);
      lineStyle([3, 1]);
      stroke;
    end;

    begin   // line 2
      beginPath;
      moveTo(20, 180);
      lineTo(220, 180);
      lineTo(240, 160);
      lineStyle([1, 1, 2, 2]);
      stroke;
    end;
  end;
  targetCanvas.surface.PutImage(0, 0, layer, dmDrawWithTransparency);
  layer.Free;
  UpdateIn(glob.UpdateInterval);
end;

procedure TForm1.Test3(targetCanvas: TBGRACanvas2D);
begin
  targetCanvas.fillStyle('rgb(1000,1000,1000)');
  targetCanvas.fillRect(0, 0, targetCanvas.Width, targetCanvas.Height);
  // Solid triangle without border
  targetCanvas.beginPath();
  targetCanvas.moveTo(100, 100);
  targetCanvas.lineTo(150, 30);
  targetCanvas.lineTo(230, 150);
  targetCanvas.closePath();
  if targetCanvas.isPointInPath(mx + 0.5, my + 0.5) then
    targetCanvas.fillStyle('rgb(1000,192,192)')
  else
    targetCanvas.fillStyle('rgb(1000,0,0)');
  targetCanvas.fill();
  //Solid triangle with border
  targetCanvas.fillStyle('rgb(0,1000,0)');
  targetCanvas.strokeStyle('rgb(0,0,1000)');
  targetCanvas.lineWidth := 8;
  targetCanvas.beginPath();
  targetCanvas.moveTo(50, 100);
  targetCanvas.lineTo(50, 220);
  targetCanvas.lineTo(210, 200);
  targetCanvas.closePath();
  if targetCanvas.isPointInPath(mx + 0.5, my + 0.5) then
    targetCanvas.fillStyle('rgb(192,1000,192)')
  else
    targetCanvas.fillStyle('rgb(0,1000,0)');
  targetCanvas.fill();
  targetCanvas.stroke();
  //Solid triangle with border
  UpdateIn(50);
end;

procedure TForm1.Test4(targetCanvas: TBGRACanvas2D; grainElapse: integer);
var
  angle: single;
  p0, p1, p2: TPointF;
begin
  Inc(test4pos, grainElapse);
  angle := test4pos * 2 * Pi / 400;
  targetCanvas.translate((targetCanvas.Width - 300) / 2,
    (targetCanvas.Height - 300) / 2);
  targetCanvas.skewx(sin(angle));

  targetCanvas.beginPath;
  targetCanvas.rect(0, 0, 300, 300);
  targetCanvas.fillStyle(CSSYellow);
  targetCanvas.strokeStyle(CSSRed);
  targetCanvas.lineWidth := 5;
  targetCanvas.strokeOverFill;

  targetCanvas.beginPath();
  // coord. centre 150,150  radius : 50 starting angle 0 end 2Pi
  targetCanvas.arc(150, 150, 50, 0, PI * 2, True); // Cercle
  targetCanvas.moveTo(100, 150); // go to the starting point of the arc
  targetCanvas.arc(100, 100, 50, PI / 2, PI, False); // Arc sens aig. montre
  targetCanvas.moveTo(150, 150); // go to the starting point of the arc
  targetCanvas.arc(200, 150, 50, 2 * PI / 2, 0, False);  // Autre cercle
  targetCanvas.lineWidth := 1;
  targetCanvas.strokeStyle(BGRABlack);
  targetCanvas.stroke();

  targetCanvas.lineJoin := 'round';

  angle := test4pos * 2 * Pi / 180;
  p0 := PointF(150, 50);
  p1 := pointF(150 + 50, 50);
  p2 := pointF(150 + 50 + cos(sin(angle) * Pi / 2) * 40, 50 +
    sin(sin(angle) * Pi / 2) * 40);
  targetCanvas.beginPath;
  targetCanvas.moveTo(p0);
  targetCanvas.arcTo(p1, p2, 30);
  targetCanvas.lineTo(p2);
  targetCanvas.lineWidth := 5;
  targetCanvas.strokeStyle(BGRA(240, 170, 0));
  targetCanvas.stroke();

  targetCanvas.beginPath;
  targetCanvas.moveTo(p0);
  targetCanvas.lineTo(p1);
  targetCanvas.lineTo(p2);
  targetCanvas.strokeStyle(BGRA(0, 0, 255));
  targetCanvas.lineWidth := 2;
  targetCanvas.stroke();

  UpdateIn(10);
end;

procedure TForm1.Test5(targetCanvas: TBGRACanvas2D; grainElapse: integer);
var
  svg: TBGRASVG;
begin
  Inc(test5pos, grainElapse);

  svg := TBGRASVG.Create;
  svg.LoadFromFile(glob.path_media_s + 'Amsterdammertje-icoon.svg');
  svg.StretchDraw(targetCanvas, taCenter, tlCenter, 0, 0, targetCanvas.Width /
    3, targetCanvas.Height);

  svg.LoadFromFile(glob.path_media_s + 'BespectacledMaleUser.svg');
  svg.StretchDraw(targetCanvas, targetCanvas.Width / 3, 0, targetCanvas.Width *
    2 / 3, targetCanvas.Height / 2);

  targetCanvas.save;
  targetCanvas.beginPath;
  targetCanvas.rect(targetCanvas.Width / 3, targetCanvas.Height / 2,
    targetCanvas.Width * 2 / 3, targetCanvas.Height / 2);
  targetCanvas.clip;
  svg.LoadFromFile(glob.path_media_s + 'Blue_gyroelongated_pentagonal_pyramid.svg');
  svg.Draw(targetCanvas, taCenter, tlCenter, targetCanvas.Width * 2 /
    3, targetCanvas.Height * 3 / 4);
  targetCanvas.restore;

  svg.Free;

  targetCanvas.beginPath;
  targetCanvas.lineWidth := 1;
  targetCanvas.strokeStyle(BGRABlack);
  targetCanvas.moveTo(targetCanvas.Width / 3, 0);
  targetCanvas.lineTo(targetCanvas.Width / 3, targetCanvas.Height);
  targetCanvas.moveTo(targetCanvas.Width / 3, targetCanvas.Height / 2);
  targetCanvas.lineTo(targetCanvas.Width, targetCanvas.Height / 2);
  targetCanvas.stroke;

  UpdateIn(20);
end;

procedure TForm1.Test6(targetCanvas: TBGRACanvas2D);
begin
  targetCanvas.fillStyle('rgb(1000,1000,1000)');
  targetCanvas.fillRect(0, 0, 300, 300);
  //Example of B2ézier curves
  targetCanvas.fillStyle('yellow');
  targetCanvas.lineWidth := 15;
  targetCanvas.lineCap := 'round'; //round butt square
  targetCanvas.lineJoin := 'miter'; //round miter bevel
  targetCanvas.strokeStyle('rgb(200,200,1000)');
  targetCanvas.beginPath();
  targetCanvas.moveTo(50, 150);
  targetCanvas.bezierCurveTo(50, 80, 100, 60, 130, 60);
  targetCanvas.bezierCurveTo(180, 60, 250, 50, 260, 130);
  targetCanvas.bezierCurveTo(150, 150, 150, 150, 120, 280);
  targetCanvas.bezierCurveTo(50, 250, 100, 200, 50, 150);
  targetCanvas.fill();
  targetCanvas.stroke();
end;

procedure TForm1.Test7(targetCanvas: TBGRACanvas2D);
var
  i: integer;
begin
  targetCanvas.fillStyle('black');
  targetCanvas.fillRect(0, 0, 300, 300);
  // Background drawing
  targetCanvas.fillStyle('red');
  targetCanvas.fillRect(0, 0, 150, 150);
  targetCanvas.fillStyle('blue');
  targetCanvas.fillRect(150, 0, 150, 150);
  targetCanvas.fillStyle('yellow');
  targetCanvas.fillRect(0, 150, 150, 150);
  targetCanvas.fillStyle('green');
  targetCanvas.fillRect(150, 150, 150, 150);
  targetCanvas.fillStyle('#FFF');
  //Definition of the transparency value
  targetCanvas.globalAlpha := 0.1;
  //Drawing of semi-transparent squares
  for i := 0 to 9 do
  begin
    targetCanvas.beginPath();
    targetCanvas.fillRect(10 * i, 10 * i, 300 - 20 * i, 300 - 20 * i);
    targetCanvas.fill();
  end;
end;

procedure TForm1.Test8(targetCanvas: TBGRACanvas2D);
begin
  targetCanvas.drawImage(img, 0, 0);
  targetCanvas.globalAlpha := 0.5;
  targetCanvas.drawImage(img, 100, 100);
  targetCanvas.globalAlpha := 0.9;
  targetCanvas.translate(100, 100);
  targetCanvas.beginPath;
  targetCanvas.moveTo(50, 50);
  targetCanvas.lineTo(300, 50);
  targetCanvas.lineTo(500, 200);
  targetCanvas.lineTo(50, 200);
  targetCanvas.fillStyle(img);
  targetCanvas.fill;
end;

procedure TForm1.Test9(targetCanvas: TBGRACanvas2D);
var
  i: integer;
  j: integer;
begin
  targetCanvas.translate(targetCanvas.Width / 2 - 15 * 10, targetCanvas.Height /
    2 - 15 * 10);
  targetCanvas.strokeStyle('#000');
  targetCanvas.lineWidth := 4;
  for i := 0 to 14 do
    for j := 0 to 14 do
    begin
      targetCanvas.fillStyle(BGRA(255 - 18 * i, 255 - 18 * j, 0));
      targetCanvas.strokeStyle(BGRA(20 + 10 * j, 20 + 8 * i, 0));
      targetCanvas.fillRect(j * 20, i * 20, 20, 20);
      targetCanvas.strokeRect(j * 20, i * 20, 20, 20);
    end;
end;

procedure TForm1.Test10(targetCanvas: TBGRACanvas2D);
var
  i: integer;
  j: integer;
begin
  targetCanvas.translate(targetCanvas.Width / 2, targetCanvas.Height / 2);
  //center 0 0 now in central position
  for i := 1 to 9 do
  begin
    targetCanvas.save(); // counterbalanced by a restore
    targetCanvas.fillStyle(BGRA(25 * i, 255 - 25 * i, 255));
    for j := 0 to i * 5 do
    begin
      targetCanvas.rotate(PI * 2 / (1 + i * 5));
      targetCanvas.beginPath();
      targetCanvas.arc(0, i * 16, 6, 0, PI * 2, True);
      targetCanvas.fill();
    end;
    targetCanvas.restore();
  end;
end;

procedure TForm1.Test11(targetCanvas: TBGRACanvas2D);
const
  sc = 20;  // number of pixels for one unit

var
  H: longint;
  W: longint;
  i: integer;
  x, u: single;

  function f(x: single): single; //function to trace
  begin
    Result := 3 * sin(x) * (cos(x) + 1 / 2 * cos(x / 2) + 1 / 3 *
      cos(x / 3) + 1 / 4 * cos(x / 4));
  end;

begin
  H := targetCanvas.Height;
  W := targetCanvas.Width;
  // grid layout
  targetCanvas.strokeStyle('#666');
  targetCanvas.beginPath();
  targetCanvas.lineWidth := 0.5;
  //horizontal lines
  for i := -trunc(H / 2 / sc) to trunc(H / 2 / sc) do
  begin
    targetCanvas.moveTo(0, H / 2 - sc * i);
    targetCanvas.lineTo(W, H / 2 - sc * i);
  end;
  // vertical lines
  for i := 0 to trunc(W / sc) do
  begin
    targetCanvas.moveTo(sc * i, H - 0);
    targetCanvas.lineTo(sc * i, H - H);
  end;
  targetCanvas.stroke();
  //function plot
  targetCanvas.strokeStyle('#ff0000');
  targetCanvas.lineWidth := 1.5;
  targetCanvas.beginPath();
  x := 0;
  u := f(x);
  targetCanvas.moveTo(0, H / 2 - u * sc);
  while x < W / sc do
  begin
    u := f(x);
    targetCanvas.lineTo(x * sc, H / 2 - u * sc);
    x += 1 / sc;
  end;
  targetCanvas.stroke();
end;

procedure TForm1.Test12(targetCanvas: TBGRACanvas2D);
var
  W: longint;
  H: longint;
  i: integer;
  j: integer;

  function color(): TBGRAPixel;
  begin
    Result := BGRA(random(256), random(256), random(256));
  end;

  procedure drawSpirograph(R2: single; r: single; O: single);
  var
    x0, x1, x2: single;
    y0, y1, y2: single;
    i: integer;
  begin
    x0 := R2 - O;
    y0 := 0;
    i := 1;
    targetCanvas.beginPath();
    x1 := x0;
    y1 := y0;
    targetCanvas.moveTo(x1, y1);
    repeat
      if (i > 1000) then
        break;
      x2 := (R2 + r) * cos(i * PI / 72) - (r + O) * cos(((R2 + r) / r) * (i * PI / 72));
      y2 := (R2 + r) * sin(i * PI / 72) - (r + O) * sin(((R2 + r) / r) * (i * PI / 72));
      targetCanvas.lineTo(x2, y2);
      x1 := x2;
      y1 := y2;
      Inc(i);
    until (abs(x2 - x0) < 1e-6) and (abs(y2 - y0) < 1e-6);
    targetCanvas.stroke();
  end;

begin
  W := targetCanvas.Width;
  H := targetCanvas.Height;
  targetCanvas.fillRect(0, 0, W, H);
  for i := 0 to 1 do
    for j := 0 to 2 do
    begin
      targetCanvas.save();
      targetCanvas.strokeStyle(color());
      targetCanvas.translate(110 + j * 200, 100 + i * 160);
      drawSpirograph(40 * (j + 2) / (j + 1), -(3 + random(11)) * (i + 3) / (i + 1), 35);
      targetCanvas.restore();
    end;

  UpdateIn(3000);
end;

procedure TForm1.Test13(targetCanvas: TBGRACanvas2D);
const
  vitesse = 1;
begin
  targetCanvas.fillStyle('#000');
  targetCanvas.fillRect(0, 0, 800, 400);
  targetCanvas.clearRect(0, 0, 800, 400);
  targetCanvas.fillRect(0, 0, 800, 400);
  targetCanvas.setTransform(-0.55, 0.85, -1, 0.10, 100, 50 + img.Width * 0.5);
  targetCanvas.rotate(PI * 2 * (Test13pos / 360) * vitesse);
  targetCanvas.drawImage(img, img.Width * (-0.5) - 200, img.Height * (-0.8));
  Test13pos += 1;
  if (Test13pos = 360) then
    Test13pos := 0;
  UpdateIn(10);
end;

procedure TForm1.Test14(targetCanvas: TBGRACanvas2D);

  procedure pave();
  begin
    targetCanvas.save();
    targetCanvas.fillStyle('rgb(130,100,800)');
    targetCanvas.strokeStyle('rgb(0,0,300)');
    targetCanvas.beginPath();
    targetCanvas.lineWidth := 2;
    targetCanvas.moveTo(5, 5);
    targetCanvas.lineTo(20, 10);
    targetCanvas.lineTo(55, 5);
    targetCanvas.lineTo(45, 18);
    targetCanvas.lineTo(30, 50);
    targetCanvas.closePath();
    targetCanvas.stroke();
    targetCanvas.fill();
    targetCanvas.fillStyle('rgb(300,300,100)');
    targetCanvas.lineWidth := 5;
    targetCanvas.strokeStyle('rgb(0,300,0)');
    targetCanvas.beginPath();
    targetCanvas.moveTo(20, 18);
    targetCanvas.lineTo(40, 16);
    targetCanvas.lineTo(35, 26);
    targetCanvas.lineTo(25, 30);
    targetCanvas.closePath();
    targetCanvas.stroke();
    targetCanvas.fill();
    targetCanvas.restore();
  end;
  //drawings of a hexagon from six pavers by rotation
  procedure six();
  var
    i: integer;
  begin
    targetCanvas.save();
    for i := 0 to 5 do
    begin
      targetCanvas.rotate(2 * PI / 6);
      pave();
    end;
    targetCanvas.restore();
  end;
  //tiling using translations according to two non-collinear vectors
  // 0,60*Math.sqrt(3)     et     60*3/2, 60*Math.sqrt(3)/2
  procedure draw();
  var
    i: integer;
    j: integer;
  begin
    targetCanvas.fillStyle('rgb(800,100,50)');
    targetCanvas.fillRect(0, 0, targetCanvas.Width, targetCanvas.Height);
    for j := 0 to (targetCanvas.Width + 60) div 90 do
    begin
      targetCanvas.save();
      targetCanvas.translate(0, (-j div 2) * 60 * sqrt(3));
      for i := 0 to round(targetCanvas.Height / (60 * sqrt(3))) do
      begin
        six();
        targetCanvas.translate(0, 60 * sqrt(3));
      end;

      targetCanvas.restore();
      targetCanvas.translate(90, sqrt(3) * 60 / 2);
    end;
  end;

begin
  draw();
end;

procedure TForm1.Test15(targetCanvas: TBGRACanvas2D);
const
  cote = 190;

  procedure pave();
  begin
    targetCanvas.drawImage(abelias, 0, 0);
  end;

  procedure refl();
  begin
    targetCanvas.save();
    pave();
    targetCanvas.transform(1, 0, 0, -1, 0, 0);
    pave();
    targetCanvas.restore();
  end;

  //drawings of a hexagon from six pavers by rotation
  procedure trois();
  var
    i: integer;
  begin
    targetCanvas.save();
    for i := 0 to 2 do
    begin
      targetCanvas.rotate(4 * PI / 6);
      refl();
    end;
    targetCanvas.restore();
  end;

  // tiling using translations according to two non-collinear vectors
  // 0,cote*Math.sqrt(3)     et     cote*3/2, cote*Math.sqrt(3)/2
  procedure draw();
  var
    i: integer;
    j: integer;
  begin
    targetCanvas.fillStyle('#330055');
    targetCanvas.fillRect(0, 0, targetCanvas.Width, targetCanvas.Height);
    targetCanvas.translate(140, 140);
    for j := 0 to trunc(targetCanvas.Width / (cote * 3 / 2)) do
    begin
      targetCanvas.save();
      targetCanvas.translate(0, -(1 / 2 + j div 2) * cote * sqrt(3));
      for i := 0 to trunc(targetCanvas.Height / (cote * sqrt(3))) + 1 do
      begin
        trois();
        targetCanvas.translate(0, cote * sqrt(3));
      end;
      targetCanvas.restore();
      targetCanvas.translate(cote * 3 / 2, sqrt(3) * cote / 2);
    end;
  end;

begin
  draw();
end;

procedure TForm1.Test16(targetCanvas: TBGRACanvas2D; grainElapse: integer);
var
  center16: TPointF;
  angle, zoom: single;
begin
  Inc(test16pos, grainElapse);
  center16 := pointf(targetCanvas.Width / 2, targetCanvas.Height / 2);
  angle := test16pos * 2 * Pi / 300;
  zoom := (sin(test16pos * 2 * Pi / 400) + 1.1) *
    min(targetCanvas.Width, targetCanvas.Height) / 300;
  with targetCanvas do
  begin
    translate(center16.X, center16.Y);
    scale(zoom, zoom);
    rotate(angle);
    translate(-93, -83);
    beginPath();
    moveTo(89.724698, 11.312043);
    bezierCurveTo(95.526308, 14.494575, 100.52322000000001, 18.838808,
      102.75144, 24.966412);
    bezierCurveTo(114.24578, 26.586847, 123.07072, 43.010127999999995,
      118.71826, 54.504664);
    bezierCurveTo(114.77805000000001, 64.910473, 93.426098, 68.10145299999999,
      89.00143800000001, 59.252123);
    bezierCurveTo(86.231818, 53.712894999999996, 90.877898, 48.213108999999996,
      88.853498, 42.139906999999994);
    bezierCurveTo(87.401408, 37.78364299999999, 82.208048, 33.87411899999999,
      85.595888, 27.098436999999993);
    bezierCurveTo(87.071858, 24.146481999999992, 94.76621800000001,
      25.279547999999995, 94.863658, 23.444067999999994);
    bezierCurveTo(95.066728, 19.618834999999994, 92.648878, 18.165403999999995,
      90.221828, 15.326465999999995);
    closePath();
    moveTo(53.024288, 20.876975);
    bezierCurveTo(50.128958, 26.827119000000003, 48.561707999999996,
      33.260252, 50.284608, 39.548662);
    bezierCurveTo(41.840728, 47.513997, 44.130318, 66.017003, 54.325338,
      72.88213300000001);
    bezierCurveTo(63.554708000000005, 79.09700300000002, 82.823918,
      69.36119300000001, 81.320528, 59.58223300000001);
    bezierCurveTo(80.379498, 53.461101000000006, 73.409408, 51.65791100000001,
      71.551608, 45.53168800000001);
    bezierCurveTo(70.219018, 41.13739400000001, 72.197818, 34.94548700000001,
      65.517188, 31.373877000000007);
    bezierCurveTo(62.606638000000004, 29.817833000000007, 56.98220800000001,
      35.18931200000001, 55.841908000000004, 33.74771500000001);
    bezierCurveTo(53.465478000000004, 30.743354000000007, 54.598668,
      28.159881000000006, 54.938648, 24.44039800000001);
    closePath();
    moveTo(16.284108, 78.650993);
    bezierCurveTo(16.615938, 85.259863, 18.344168, 91.651623, 22.885208, 96.330453);
    bezierCurveTo(19.327327999999998, 107.37975, 30.253377999999998,
      122.48687000000001, 42.495058, 123.58667);
    bezierCurveTo(53.577238, 124.58229, 65.765908, 106.76307, 59.734438, 98.920263);
    bezierCurveTo(55.959047999999996, 94.01106300000001, 48.983098,
      95.791453, 44.402058, 91.319753);
    bezierCurveTo(41.116108, 88.112233, 39.864737999999996, 81.73340300000001,
      32.289848, 81.824883);
    bezierCurveTo(28.989708, 81.864783, 26.651538, 89.282293, 24.957518, 88.569003);
    bezierCurveTo(21.427108, 87.08246299999999, 21.174458, 84.272723,
      19.679208, 80.85010299999999);
    closePath();
    moveTo(152.77652, 37.616125);
    bezierCurveTo(156.68534, 42.955439, 159.37334, 49.006564, 158.79801, 55.501293);
    bezierCurveTo(168.5256, 61.835313, 169.5682, 80.450283, 160.75895, 89.021463);
    bezierCurveTo(152.78409, 96.780823, 132.08894, 90.63274299999999,
      131.82654, 80.742363);
    bezierCurveTo(131.6623, 74.551503, 138.19976, 71.535693, 138.93671,
      65.17653299999999);
    bezierCurveTo(139.46532, 60.615162999999995, 136.41531, 54.87470199999999,
      142.35299, 50.170306999999994);
    bezierCurveTo(144.93985, 48.12074299999999, 151.43107, 52.404562999999996,
      152.29636, 50.78291599999999);
    bezierCurveTo(154.09968999999998, 47.403324999999995, 152.52446999999998,
      45.062994999999994, 151.52745, 41.463536999999995);
    closePath();
    moveTo(139.65359, 109.38478);
    bezierCurveTo(179.13505, 123.79982000000001, 142.51298, 146.31478,
      119.19800000000001, 151.55864);
    bezierCurveTo(95.883018, 156.8025, 41.93790800000001, 157.82316,
      75.508908, 123.02183);
    bezierCurveTo(78.980078, 119.42344999999999, 79.61785800000001,
      104.19731999999999, 82.074898, 99.283253);
    bezierCurveTo(86.361158, 93.329663, 106.23528, 86.908083, 113.13709, 88.929193);
    bezierCurveTo(128.23085, 93.960443, 125.96716, 106.89633, 139.65359, 109.38478);
    closePath();
    if isPointInPath(mx + 0.5, my + 0.5) then
      fillStyle('#6faed9')
    else
      fillStyle('#3f5e99');
    fill();
  end;
  UpdateIn(10);
end;

procedure TForm1.Test17(targetCanvas: TBGRACanvas2D; grainElapse: integer);
var
  grad: IBGRACanvasGradient2D;
  angle: single;
begin
  Inc(test17pos, grainElapse);
  angle := test17pos * 2 * Pi / 1000;

  targetCanvas.translate(targetCanvas.Width / 2, targetCanvas.Height / 2);
  targetCanvas.scale(min(targetCanvas.Width, targetCanvas.Height) / 2 - 10);
  targetCanvas.rotate(angle);

  grad := targetCanvas.createLinearGradient(-1, -1, 1, 1);
  grad.addColorStop(0.3, '#ff0000');
  grad.addColorStop(0.6, '#0000ff');
  targetCanvas.fillStyle(grad);

  grad := targetCanvas.createLinearGradient(-1, -1, 1, 1);
  grad.addColorStop(0.3, '#ffffff');
  grad.addColorStop(0.6, '#000000');
  targetCanvas.strokeStyle(grad);
  targetCanvas.lineWidth := 5;

  targetCanvas.beginPath;
  targetCanvas.moveto(0, 0);
  targetCanvas.arc(0, 0, 1, Pi / 6, -Pi / 6, False);
  targetCanvas.fill();
  targetCanvas.stroke();

  UpdateIn(10);
end;

procedure TForm1.Test18(targetCanvas: TBGRACanvas2D; grainElapse: integer);
var
  pat: TBGRABitmap;
begin
  Inc(test18pos, grainElapse);
  targetCanvas.translate(targetCanvas.Width div 2, targetCanvas.Height div 2);
  targetCanvas.rotate(test18pos * 2 * Pi / 360);
  targetCanvas.scale(3, 3);
  pat := TBGRABitmap.Create(8, 8);
  pat.GradientFill(0, 0, 8, 8, BGRABlack, BGRAWhite, gtLinear,
    PointF(0, 0), PointF(8, 8), dmSet);
  //  targetCanvas.surface.CreateBrushTexture(bsDiagCross,BGRA(255,255,0),BGRA(255,0,0)) as TBGRABitmap;
  targetCanvas.fillStyle(targetCanvas.createPattern(pat, 'repeat-x'));
  targetCanvas.fillRect(0, 0, targetCanvas.Width, pat.Height - 1);
  targetCanvas.fillStyle(targetCanvas.createPattern(pat, 'repeat-y'));
  targetCanvas.fillRect(0, 0, pat.Width - 1, targetCanvas.Height);

  targetCanvas.rotate(Pi);
  targetCanvas.globalAlpha := 0.25;
  targetCanvas.fillStyle(targetCanvas.createPattern(pat, 'repeat-x'));
  targetCanvas.fillRect(0, 0, targetCanvas.Width, targetCanvas.Height);
  targetCanvas.fillStyle(targetCanvas.createPattern(pat, 'repeat-y'));
  targetCanvas.fillRect(0, 0, targetCanvas.Width, targetCanvas.Height);
  pat.Free;

  UpdateIn(10);
end;

procedure TForm1.Test19(targetCanvas: TBGRACanvas2D; grainElapse: integer);
var
  i: integer;
  tx, ty: single;
begin
  Inc(test19pos, grainElapse);
  targetCanvas.save;
  targetCanvas.translate(targetCanvas.Width div 2, targetCanvas.Height div 2);
  targetCanvas.rotate(test19pos * 2 * Pi / 500);
  targetCanvas.scale(targetCanvas.Height / 2, targetCanvas.Height / 2);
  targetCanvas.beginPath;
  targetCanvas.moveto(1, 0);
  for i := 1 to 8 do
  begin
    targetCanvas.rotate(2 * Pi / 8);
    targetCanvas.lineto(1, 0);
  end;
  targetCanvas.restore;
  targetCanvas.clip;

  tx := targetCanvas.Width div 2;
  ty := targetCanvas.Height div 2;
  targetCanvas.fillStyle('red');
  targetCanvas.fillRect(0, 0, tx, ty);
  targetCanvas.fillStyle('blue');
  targetCanvas.fillRect(tx, 0, tx, ty);

  targetCanvas.globalAlpha := 0.75;
  targetCanvas.fillStyle('yellow');
  targetCanvas.fillRect(0, ty, tx, ty);
  targetCanvas.fillStyle('green');
  targetCanvas.fillRect(tx, ty, tx, ty);

  test18(targetCanvas, grainElapse);
end;

procedure TForm1.Test20(targetCanvas: TBGRACanvas2D; AVectorizedFont: boolean);
var
  i: integer;
  grad: IBGRACanvasGradient2D;
begin
  UseVectorizedFont(targetCanvas, AVectorizedFont);
  targetCanvas.save;

  targetCanvas.fontName := 'default';
  targetCanvas.fontEmHeight := targetCanvas.Height / 10;
  targetCanvas.textBaseline := 'alphabetic';

  targetCanvas.beginPath;
  if AVectorizedFont then
    targetCanvas.Text('Vectorized font', targetCanvas.fontEmHeight *
      0.2, targetCanvas.fontEmHeight)
  else
    targetCanvas.Text('Raster font', targetCanvas.fontEmHeight * 0.2,
      targetCanvas.fontEmHeight);
  targetCanvas.lineWidth := 2;
  targetCanvas.strokeStyle(clLime);
  targetCanvas.fillStyle(clBlack);
  targetCanvas.fillOverStroke;

  grad := targetCanvas.createLinearGradient(0, 0, targetCanvas.Width,
    targetCanvas.Height);
  grad.addColorStop(0.3, '#000080');
  grad.addColorStop(0.7, '#00a0a0');
  targetCanvas.fillStyle(grad);

  targetCanvas.translate(targetCanvas.Width / 2, targetCanvas.Height / 2);

  for i := 0 to 11 do
  begin
    targetCanvas.beginPath;
    targetCanvas.moveTo(0, 0);
    targetCanvas.lineTo(targetCanvas.Width + targetCanvas.Height, 0);
    targetCanvas.strokeStyle(clRed);
    targetCanvas.lineWidth := 1;
    targetCanvas.stroke;

    targetCanvas.beginPath;
    targetCanvas.Text('hello', targetCanvas.Width / 10, 0);
    targetCanvas.fill;
    targetCanvas.rotate(Pi / 6);
  end;
  targetCanvas.restore;
  targetCanvas.fontRenderer := nil;
end;

procedure TForm1.Test22(targetCanvas: TBGRACanvas2D);
var
  layer: TBGRABitmap;
begin
  layer := TBGRABitmap.Create(targetCanvas.Width, targetCanvas.Height, CSSRed);
  with layer.Canvas2D do
  begin
    pixelCenteredCoordinates := targetCanvas.pixelCenteredCoordinates;
    antialiasing := targetCanvas.antialiasing;
    fontName := 'default';
    fontStyle := [fsBold];
    fontEmHeight := min(targetCanvas.Height / 2, targetCanvas.Width / 4);
    textBaseline := 'middle';
    textAlign := 'center';

    beginPath;
    Text('hole', Width / 2, Height / 2);
    clearPath;
  end;
  targetCanvas.surface.DrawCheckers(rect(0, 0, targetCanvas.Width, targetCanvas.Height),
    CSSWhite, CSSSilver);
  targetCanvas.surface.PutImage(0, 0, layer, dmDrawWithTransparency);
end;

procedure TForm1.Test23(targetCanvas: TBGRACanvas2D; grainElapse: integer);
begin
  UseVectorizedFont(targetCanvas, True);
  with targetCanvas do
  begin
    save;
    fontName := 'default';
    fontStyle := [fsBold];
    fontEmHeight := min(Height / 2, Width / 6);
    textBaseline := 'middle';
    textAlign := 'center';

    translate(Width / 2, Height / 2);
    transform(cos(test23pos * Pi / 60), sin(test23pos * Pi / 60), 0, 1, 0, 0);
    beginPath;
    Text('distort', 0, 0);
    fillStyle(clBlack);
    fill;
    restore;
  end;
  Inc(test23pos, grainElapse);
  UpdateIn(10);
end;

procedure TForm1.Test24(targetCanvas: TBGRACanvas2D);
var
  me: string;

begin
  me := 'Test24[' + val.ts(counter1) + ']: ';
  //glob.toMemo(me+'Started ');
  counter1 := counter1 + 1;

  if (mx < 0) or (my < 0) then
  begin
    mx := 0;// targetCanvas.Width div 2;
    my := 0;//targetCanvas.Height div 2;
  end;

  //set background
  targetCanvas.fillStyle('rgb(255,255,255)');
  targetCanvas.fillRect(0, 0, targetCanvas.Width, targetCanvas.Height);
  CenterOfDrawing := Point(targetCanvas.Width div 2,
    (targetCanvas.Height - self.Pnl_1.Height - self.Memo_dbg.Height) div
    2 + self.Pnl_1.Height + self.Memo_dbg.Height);

  //unknown directives
  bounds := RectF(0, 0, targetCanvas.Width, targetCanvas.Height);
  bounds.Offset(-CenterOfDrawing.X, -CenterOfDrawing.Y);
  targetCanvas.resetTransform;
  targetCanvas.translate(CenterOfDrawing.X, CenterOfDrawing.Y);
  //targetCanvas.lineJoinLCL := pjsBevel;

  //BezierCurve
  //toMemo(me+'beziersDefined is: '+val.ts(beziersDefined));
  if not beziersDefined then
  begin
    weight := 2;
    B1 := BezierCurve(PointF(-150, 80), PointF(0, 0), PointF(150, 80), -weight);
    B2 := BezierCurve(B1.p1, B1.c, B1.p2, weight);
    beziersDefined := True;
  end;

  precision := 0.5;
  begin // visualize BezierCurve B1 (with complementary curve) in green
    targetCanvas.beginPath;
    targetCanvas.strokeStyle(BGRA(96, 160, 0, 255));
    targetCanvas.polylineTo(B1.ToPoints(bounds, precision));
    targetCanvas.linewidth := 4;
    targetCanvas.stroke();
  end;

  begin // visualize BezierCurve B2 in red, completes the compl part of green B1
    targetCanvas.beginPath;
    targetCanvas.lineWidth := 4;
    targetCanvas.strokeStyle(BGRA(255, 0, 96, 255));
    targetCanvas.moveTo(B2.p1);// Moves to a loc., disconn. from prev. points
    targetCanvas.polylineTo(B2.ToPoints(bounds, precision));
    targetCanvas.stroke();
  end;

  begin // control circles visual connection lines
    targetCanvas.beginPath;
    targetCanvas.moveto(B2.p1);
    targetCanvas.lineTo(B2.c);
    targetCanvas.lineTo(B2.p2);
    targetCanvas.moveto(B1.p1);
    targetCanvas.lineTo(B1.c);
    targetCanvas.lineTo(B1.p2);
    targetCanvas.moveto(B2.p1.x + 5, B2.p1.y);
    targetCanvas.strokeStyle(BGRA(0, 0, 0, 190));
    targetCanvas.linewidth := 1.5;
    targetCanvas.stroke();
  end;

  begin // control circles
    targetCanvas.beginPath;
    targetCanvas.circle(B2.p1.x, B2.p1.y, ControlCircleRadius);
    targetCanvas.moveto(B2.c.x + 5, B2.c.y);
    targetCanvas.circle(B2.c.x, B2.c.y, ControlCircleRadius);
    targetCanvas.moveto(B2.p2.x + 5, B2.p2.y);
    targetCanvas.circle(B2.p2.x, B2.p2.y, ControlCircleRadius);
    targetCanvas.strokeStyle(BGRA(0, 0, 0, 190));
    targetCanvas.linewidth := 1.5;
    targetCanvas.stroke();
  end;

  if (mouseBtnCurrent = 'left') and (ControlDetected = '') then
  begin
    glob.toMemo(me + 'Detecting control under cursor');
    CenterOfDrawing := Point(targetCanvas.Width div 2,
      (targetCanvas.Height - self.Pnl_1.Height - self.Memo_dbg.Height) div
      2 + self.Pnl_1.Height + self.Memo_dbg.Height);
    relX := mx - CenterOfDrawing.X;
    relY := my - CenterOfDrawing.Y;
    //toMemo(' absolute coordinates (x;y): ' + val.ts(mx) + '; ' + val.ts(my));
    //toMemo(' relative coordinates (x;y): ' + val.ts(relX) + '; ' + val.ts(relY));
    minimalDistance := sqr(15);
    if sqr(B2.p1.x - relX) + sqr(B2.p1.y - relY) < minimalDistance then
    begin
      ControlDetected := 'B2.p1';
      PrevMousePos := Point(relX, relY);
      glob.toMemo(me + '  - ControlDetected is: ' + ControlDetected);
    end
    else if sqr(B2.c.x - relX) + sqr(B2.c.y - relY) < minimalDistance then
    begin
      ControlDetected := 'B2.c';
      PrevMousePos := Point(relX, relY);
      glob.toMemo(me + '  - ControlDetected is: ' + ControlDetected);
    end
    else if sqr(B2.p2.x - relX) + sqr(B2.p2.y - relY) < minimalDistance then
    begin
      ControlDetected := 'B2.p2';
      PrevMousePos := Point(relX, relY);
      glob.toMemo(me + '  - ControlDetected is: ' + ControlDetected);
    end
    else
      glob.toMemo(me + ' - no Controls detected ');

  end; // detecting control

  //Moving control
  if (mouseBtnCurrent = 'left') and (ControlDetected <> '') then
  begin
    glob.toMemo(me + 'Moving control ' + ControlDetected);
    CenterOfDrawing := Point(targetCanvas.Width div 2,
      (targetCanvas.Height - self.Pnl_1.Height - self.Memo_dbg.Height) div
      2 + self.Pnl_1.Height + self.Memo_dbg.Height);
    relX := mx - CenterOfDrawing.X;
    relY := my - CenterOfDrawing.Y;
    d := PointF(relX - PrevMousePos.X, relY - PrevMousePos.Y);
    glob.toMemo(me + '; d= ' + val.ts(d) + '; relX: ' + val.ts(relX) +
      '; relY:' + val.ts(relY));
    if ControlDetected = 'B2.p1' then
    begin
      glob.toMemo(me + '   - moving ' + ControlDetected);
      glob.toMemo(me + '   - old ' + ControlDetected + val.ts(B1.p1) +
        '; ' + val.ts(B2.p1));
      B1.p1 += d;
      B2.p1 += d;
      glob.toMemo(me + '   - new ' + ControlDetected + ': ' +
        val.ts(B1.p1) + '; ' + val.ts(B2.p1));
    end;
    if ControlDetected = 'B2.c' then
    begin
      glob.toMemo(me + '   - moving ' + ControlDetected);
      glob.toMemo(me + '   - old ' + ControlDetected + ': ' +
        val.ts(B1.c) + '; ' + val.ts(B2.c));
      B1.c += d;
      B2.c += d;
      glob.toMemo(me + '   - new ' + ControlDetected + ': ' +
        val.ts(B1.c) + '; ' + val.ts(B2.c));
    end;
    if ControlDetected = 'B2.p2' then
    begin
      glob.toMemo(me + '   - moving ' + ControlDetected);
      glob.toMemo(me + '   - old ' + ControlDetected + ': ' +
        val.ts(B1.p2) + '; ' + val.ts(B2.p2));
      B1.p2 += d;
      B2.p2 += d;
      glob.toMemo(me + '   - new ' + ControlDetected + ': ' +
        val.ts(B1.p2) + '; ' + val.ts(B2.p2));
    end;
    PrevMousePos := Point(relX, relY);
    glob.toMemo(me + 'Moving control end');
  end; //Moving control

  //mouse up
  if (mouseBtnCurrent = '') and (ControlDetected <> '') then
  begin
    glob.toMemo(me + 'Mouse up. Reseting ControlDetected');
    ControlDetected := '';
  end;

  //glob.toMemo(me+'Finished');
  UpdateIn(glob.UpdateInterval);
end; //Test24

initialization


end.

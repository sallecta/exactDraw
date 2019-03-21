unit form_1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Spin,
  ExtCtrls, StdCtrls, BGRAVirtualScreen, BGRABitmap, BGRABitmapTypes,
  BGRACanvas2D;

const
  timeGrain = 15 / 1000 / 60 / 60 / 24;

type

  { TForm1 }

  Tform_1 = class(TForm)
    constructor Create({!}AOwner: TComponent); override;
  var //fields can't appear after method, let's use vars instead
    Btn_toDataURL: TButton;
    ChBx_Antialias: TCheckBox;
    ChBox_pixCentered: TCheckBox;
    Pnl_1: TPanel;
    DlgSave_1: TSaveDialog;
    SpinEd_1: TSpinEdit;
    VirtScreen: TBGRAVirtualScreen;
    Memo_dbg: TMemo;
    Tmr_1: TTimer;

    procedure Btn_toDataURLClick(Sender: TObject);
    procedure ChBx_AntialiasChange(Sender: TObject);
    procedure ChBox_pixCenteredChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseLeave(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; {%H-}Shift: TShiftState;
    {%H-}X, {%H-}Y: integer);
    //procedure FormPaint(Sender: TObject);
    procedure SpinEd_1Change(Sender: TObject);
    procedure Tmr_1Timer(Sender: TObject);
    procedure VirtScreenMouseLeave(Sender: TObject);
    procedure VirtScreenMouseMove(Sender: TObject; {%H-}Shift: TShiftState;
      X, Y: integer);
    procedure VirtScreenRedraw(Sender: TObject; Bitmap: TBGRABitmap);
  private
    { private declarations }
    mx, my: integer;
    lastTime: TDateTime;
    timeGrainAcc: double;
    test4pos, test5pos, Test13pos, test16pos, test17pos, test18pos,
    test19pos, test23pos: integer;
    img, abelias: TBGRABitmap;
    procedure UpdateIn(ms: integer);
    procedure UseVectorizedFont(drawingArea: TBGRACanvas2D; AUse: boolean);
  public
    { public declarations }
    procedure Test1(drawingArea: TBGRACanvas2D);
    procedure Test2(drawingArea: TBGRACanvas2D);
    procedure Test3(drawingArea: TBGRACanvas2D);
    procedure Test4(drawingArea: TBGRACanvas2D; grainElapse: integer);
    procedure Test5(drawingArea: TBGRACanvas2D; grainElapse: integer);
    procedure Test6(drawingArea: TBGRACanvas2D);
    procedure Test7(drawingArea: TBGRACanvas2D);
    procedure Test8(drawingArea: TBGRACanvas2D);
    procedure Test9(drawingArea: TBGRACanvas2D);
    procedure Test10(drawingArea: TBGRACanvas2D);
    procedure Test11(drawingArea: TBGRACanvas2D);
    procedure Test12(drawingArea: TBGRACanvas2D);
    procedure Test13(drawingArea: TBGRACanvas2D);
    procedure Test14(drawingArea: TBGRACanvas2D);
    procedure Test15(drawingArea: TBGRACanvas2D);
    procedure Test16(drawingArea: TBGRACanvas2D; grainElapse: integer);
    procedure Test17(drawingArea: TBGRACanvas2D; grainElapse: integer);
    procedure Test18(drawingArea: TBGRACanvas2D; grainElapse: integer);
    procedure Test19(drawingArea: TBGRACanvas2D; grainElapse: integer);
    procedure Test20(drawingArea: TBGRACanvas2D; AVectorizedFont: boolean);
    procedure Test22(drawingArea: TBGRACanvas2D);
    procedure Test23(drawingArea: TBGRACanvas2D; grainElapse: integer);
    procedure Test24(drawingArea: TBGRACanvas2D);
  end;

implementation

uses BGRAGradientScanner, Math, BGRASVG, BGRAVectorize,
  gvars;

//{$R form_1.lfm}

{ TForm1 }
{resourceless form}
constructor Tform_1.Create(AOwner: TComponent);
begin

  {!}inherited CreateNew(AOwner, 1);{!}
  Caption := gvars.appname;
  Left := 567;
  Top := 83;
  Width := 720;
  Height := 600;
  ClientWidth := Width;
  ClientHeight := Height;

  //OnCreate := @FormCreate;
  OnDestroy := @FormDestroy;
  OnMouseLeave := @FormMouseLeave;
  OnMouseMove := @FormMouseMove;
  //OnPaint := @FormPaint;
  img := TBGRABitmap.Create(gvars.path_media_s + 'pteRaz.jpg');
  abelias := TBGRABitmap.Create(gvars.path_media_s + 'abelias.png');
  mx := -1000;
  my := -1000;
  lastTime := Now;
  {Form Controls}
  Pnl_1 := TPanel.Create(Self);
  Pnl_1.AutoSize := False;
  Pnl_1.Height := 48;
  Pnl_1.Left := 0;
  Pnl_1.Top := 0;
  Pnl_1.Align := alTop;
  //Pnl_1.Color := $0000FBFF;
  //Pnl_1.BevelColor := clRed;
  //Pnl_1.BevelInner := bvNone;
  //Pnl_1.BevelOuter := bvSpace;
  //Pnl_1.BevelWidth := 1;
  Pnl_1.TabOrder := 1;
  Pnl_1.Parent := self;  //self is instance of tform_1

  SpinEd_1 := TSpinEdit.Create(Pnl_1);
  SpinEd_1.AutoSize := True;
  SpinEd_1.AnchorSideLeft.Control := Pnl_1;
  SpinEd_1.AnchorSideTop.Control := Pnl_1;
  SpinEd_1.AnchorSideBottom.Control := Pnl_1;
  SpinEd_1.AnchorSideBottom.Side := asrBottom;
  SpinEd_1.Anchors := [akTop, akLeft, akBottom];
  SpinEd_1.BorderSpacing.Left := 8;
  SpinEd_1.BorderSpacing.Top := 8;
  SpinEd_1.BorderSpacing.Right := 8;
  SpinEd_1.BorderSpacing.Bottom := 8;
  SpinEd_1.Increment := 1;
  SpinEd_1.MaxValue := 24 + SpinEd_1.Increment;//provides loop to beginning
  SpinEd_1.MinValue := 1 - SpinEd_1.Increment;//provides loop to end
  SpinEd_1.TabOrder := 0;
  SpinEd_1.Value := 1;
  if gvars.wine then
    SpinEd_1.Font.Size := 14;
  SpinEd_1.AutoSelect := False;
  SpinEd_1.OnChange := @SpinEd_1Change;
  SpinEd_1.Parent := Pnl_1;

  ChBox_pixCentered := TCheckBox.Create(Pnl_1);
  ChBox_pixCentered.AutoSize := True;
  ChBox_pixCentered.AnchorSideLeft.Control := SpinEd_1;
  ChBox_pixCentered.AnchorSideLeft.Side := asrBottom;
  ChBox_pixCentered.AnchorSideTop.Control := Pnl_1;
  ChBox_pixCentered.AnchorSideTop.Side := asrCenter;
  ChBox_pixCentered.AnchorSideBottom.Control := Pnl_1;
  ChBox_pixCentered.AnchorSideBottom.Side := asrBottom;
  ChBox_pixCentered.Anchors := [akTop, akLeft, akBottom];
  ChBox_pixCentered.BorderSpacing.Left := 8;
  ChBox_pixCentered.BorderSpacing.Top := 8;
  ChBox_pixCentered.BorderSpacing.Bottom := 8;
  ChBox_pixCentered.Caption := gvars.msg.Get('PixCentCoord');
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
  Btn_toDataURL.Caption := gvars.msg.Get('toDataURL');
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
  ChBx_Antialias.Caption := gvars.msg.Get('antialias');
  ChBx_Antialias.Checked := True;
  ChBx_Antialias.OnChange := @ChBx_AntialiasChange;
  ChBx_Antialias.State := cbChecked;
  ChBx_Antialias.TabOrder := 3;
  ChBx_Antialias.Parent := Pnl_1;

  Tmr_1 := TTimer.Create(self);//self is instance of tform_1           ;
  Tmr_1.OnTimer := @Tmr_1Timer;

  DlgSave_1 := TSaveDialog.Create(self);//self is instance of tform_1        ;
  DlgSave_1.Title := gvars.msg.Get('saveAsHtm');
  DlgSave_1.DefaultExt := '.html';
  DlgSave_1.Filter := gvars.msg.Get('HtmFile');

  Memo_dbg := TMemo.Create(self);
  Memo_dbg.AnchorSideLeft.Control := self;  //self is instance of tform_1
  Memo_dbg.AnchorSideTop.Control := VirtScreen;
  Memo_dbg.AnchorSideTop.Side := asrBottom;
  Memo_dbg.AnchorSideRight.Control := self;  //self is instance of tform_1
  Memo_dbg.AnchorSideRight.Side := asrBottom;
  Memo_dbg.AnchorSideBottom.Control := self;  //self is instance of tform_1
  Memo_dbg.AnchorSideBottom.Side := asrBottom;
  Memo_dbg.Anchors := [akLeft, akRight, akBottom];
  Memo_dbg.Lines.Add(gvars.msg.Get('Memo_dbg_caption'));
  Memo_dbg.Height := 80;
  Memo_dbg.ScrollBars := ssBoth;
  Memo_dbg.Parent := self;  //self is instance of tform_1

  VirtScreen := TBGRAVirtualScreen.Create(Self);
  VirtScreen.AutoSize := True;
  VirtScreen.AnchorSideLeft.Control := self;//self is instance of tform_1
  VirtScreen.AnchorSideTop.Control := Pnl_1;
  VirtScreen.AnchorSideTop.Side := asrBottom;
  VirtScreen.AnchorSideRight.Control := self;//self is instance of tform_1
  VirtScreen.AnchorSideRight.Side := asrBottom;
  VirtScreen.AnchorSideBottom.Control := Memo_dbg;//self is instance of tform_1
  VirtScreen.AnchorSideBottom.Side := asrTop;
  VirtScreen.Anchors := [akTop, akLeft, akRight, akBottom];
  VirtScreen.ParentColor := False;
  VirtScreen.TabOrder := 0;
  VirtScreen.OnRedraw := @VirtScreenRedraw;
  VirtScreen.OnMouseLeave := @VirtScreenMouseLeave;
  VirtScreen.OnMouseMove := @VirtScreenMouseMove;
  VirtScreen.Parent := self;  //self is instance of tform_1

end;

{end resourceless form}


procedure Tform_1.FormCreate(Sender: TObject);
begin
  img := TBGRABitmap.Create(gvars.path_media_s + 'pteRaz.jpg');
  abelias := TBGRABitmap.Create(gvars.path_media_s + 'abelias.png');
  mx := -1000;
  my := -1000;
  lastTime := Now;
end;

procedure Tform_1.ChBox_pixCenteredChange(Sender: TObject);
begin
  VirtScreen.DiscardBitmap;
end;

procedure Tform_1.Btn_toDataURLClick(Sender: TObject);
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
    MessageDlg(gvars.msg.Get('DlgSave_toDataURL'), gvars.msg.Get('DlgSave_Out') +
      DlgSave_1.FileName, mtInformation, [mbOK], 0);
  end;
end;

procedure Tform_1.ChBx_AntialiasChange(Sender: TObject);
begin
  VirtScreen.DiscardBitmap;
end;

procedure Tform_1.FormDestroy(Sender: TObject);
begin
  img.Free;
  abelias.Free;
end;

procedure Tform_1.FormMouseLeave(Sender: TObject);
begin

end;

procedure Tform_1.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin

end;

procedure Tform_1.SpinEd_1Change(Sender: TObject);
begin
  //spin edit loop from min value + increment to max value - increment
  if gvars.form1.SpinEd_1.Value = gvars.form1.SpinEd_1.MaxValue then
    gvars.form1.SpinEd_1.Value :=
      gvars.form1.SpinEd_1.MinValue + gvars.form1.SpinEd_1.Increment
  else if gvars.form1.SpinEd_1.Value = gvars.form1.SpinEd_1.MinValue then
    gvars.form1.SpinEd_1.Value :=
      gvars.form1.SpinEd_1.MaxValue - gvars.form1.SpinEd_1.Increment
  else
  begin
    VirtScreen.DiscardBitmap;
    //sroll down
    self.Memo_dbg.VertScrollBar.Position :=
      self.Memo_dbg.Lines.Capacity * self.Memo_dbg.VertScrollBar.Page;
    if self.Memo_dbg.Lines.Capacity = (gvars.form1.SpinEd_1.MaxValue-1) then
    begin
      self.Memo_dbg.Lines.Clear;
    end;
    self.Memo_dbg.Lines.Add('test' + IntToStr(SpinEd_1.Value));
  end;
end;

procedure Tform_1.Tmr_1Timer(Sender: TObject);
begin
  Tmr_1.Enabled := False;
  VirtScreen.DiscardBitmap;
end;

procedure Tform_1.VirtScreenMouseLeave(Sender: TObject);
begin
  mx := -1000;
  my := -1000;
end;

procedure Tform_1.VirtScreenMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  mx := X;
  my := Y;
  if (SpinEd_1.Value = 1) and not Tmr_1.Enabled then
    UpdateIn(10);
end;

procedure Tform_1.VirtScreenRedraw(Sender: TObject; Bitmap: TBGRABitmap);
var
  drawingArea: TBGRACanvas2D;
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

  drawingArea := Bitmap.Canvas2D;
  drawingArea.antialiasing := ChBx_Antialias.Checked;
  drawingArea.pixelCenteredCoordinates := ChBox_pixCentered.Checked;
  drawingArea.save;

  case SpinEd_1.Value of
    1: Test1(drawingArea);
    2: Test2(drawingArea);
    3: Test3(drawingArea);
    4: Test4(drawingArea, grainElapse);
    5: Test5(drawingArea, grainElapse);
    6: Test6(drawingArea);
    7: Test7(drawingArea);
    8: Test8(drawingArea);
    9: Test9(drawingArea);
    10: Test10(drawingArea);
    11: Test11(drawingArea);
    12: Test12(drawingArea);
    13: Test13(drawingArea);
    14: Test14(drawingArea);
    15: Test15(drawingArea);
    16: Test16(drawingArea, grainElapse);
    17: Test17(drawingArea, grainElapse);
    18: Test18(drawingArea, grainElapse);
    19: Test19(drawingArea, grainElapse);
    20: Test20(drawingArea, False);
    21: Test20(drawingArea, True);
    22: Test22(drawingArea);
    23: Test23(drawingArea, grainElapse);
    24: Test24(drawingArea);
  end;
  drawingArea.restore;
end;

procedure Tform_1.UpdateIn(ms: integer);
begin
  Tmr_1.Interval := ms;
  Tmr_1.Enabled := False;
  Tmr_1.Enabled := True;
end;

procedure Tform_1.UseVectorizedFont(drawingArea: TBGRACanvas2D; AUse: boolean);
begin
  if AUse and not (drawingArea.fontRenderer is TBGRAVectorizedFontRenderer) then
    drawingArea.fontRenderer := TBGRAVectorizedFontRenderer.Create;
  if not AUse and (drawingArea.fontRenderer is TBGRAVectorizedFontRenderer) then
    drawingArea.fontRenderer := nil;
end;

procedure Tform_1.Test1(drawingArea: TBGRACanvas2D);
var
  colors: TBGRACustomGradient;
begin
  if (mx < 0) or (my < 0) then
  begin
    mx := drawingArea.Width div 2;
    my := drawingArea.Height div 2;
  end;
  drawingArea.fillStyle('rgb(1000,1000,1000)');
  //out of bounds so it is saturated to 255,255,255
  drawingArea.fillRect(0, 0, drawingArea.Width, drawingArea.Height);
  colors := TBGRAMultiGradient.Create([BGRA(0, 255, 0), BGRA(0, 192, 128),
    BGRA(0, 255, 0)], [0, 0.5, 1], True, True);
  drawingArea.fillStyle(drawingArea.createLinearGradient(0, 0, 20, 0, colors));
  drawingArea.shadowOffset := PointF(5, 5);
  drawingArea.shadowColor('rgba(0,0,0,0.5)');
  drawingArea.shadowBlur := 4;
  drawingArea.fillRect(mx - 100, my - 100, 200, 200);
  colors.Free;
end;

procedure Tform_1.Test2(drawingArea: TBGRACanvas2D);
var
  layer: TBGRABitmap;
begin
  layer := TBGRABitmap.Create(drawingArea.Width, drawingArea.Height);
  with layer.Canvas2D do
  begin
    pixelCenteredCoordinates := drawingArea.pixelCenteredCoordinates;
    antialiasing := drawingArea.antialiasing;

    fillStyle('rgb(1000,0,0)'); //red color background
    beginPath;
    roundRect(25, 25, Width - 50, Height - 50, 25); // filling a square 250x250
    fill;

    clearRect(Width - mx - 25, Height - my - 25, 50, 50); // erase a square

    beginPath;
    arc(mx, my, 30, 0, 2 * Pi);
    clearPath;

    strokeStyle('rgb(0,0,1000)'); // contour de couleur bleue
    strokeRect(100, 100, 20, 20); //outline of a square

    shadowOffset := PointF(3, 3);
    shadowColor('rgba(0,0,0,0.5)');
    shadowBlur := 4;

    beginPath;
    lineWidth := 3;
    moveTo(20, 160);
    lineTo(200, 160);
    lineStyle([3, 1]);
    stroke;

    beginPath;
    moveTo(20, 180);
    lineTo(220, 180);
    lineTo(240, 160);
    lineStyle([1, 1, 2, 2]);
    stroke;
  end;
  drawingArea.surface.PutImage(0, 0, layer, dmDrawWithTransparency);
  layer.Free;
  UpdateIn(10);
end;

procedure Tform_1.Test3(drawingArea: TBGRACanvas2D);
begin
  drawingArea.fillStyle('rgb(1000,1000,1000)');
  drawingArea.fillRect(0, 0, drawingArea.Width, drawingArea.Height);
  // Solid triangle without border
  drawingArea.beginPath();
  drawingArea.moveTo(100, 100);
  drawingArea.lineTo(150, 30);
  drawingArea.lineTo(230, 150);
  drawingArea.closePath();
  if drawingArea.isPointInPath(mx + 0.5, my + 0.5) then
    drawingArea.fillStyle('rgb(1000,192,192)')
  else
    drawingArea.fillStyle('rgb(1000,0,0)');
  drawingArea.fill();
  //Solid triangle with border
  drawingArea.fillStyle('rgb(0,1000,0)');
  drawingArea.strokeStyle('rgb(0,0,1000)');
  drawingArea.lineWidth := 8;
  drawingArea.beginPath();
  drawingArea.moveTo(50, 100);
  drawingArea.lineTo(50, 220);
  drawingArea.lineTo(210, 200);
  drawingArea.closePath();
  if drawingArea.isPointInPath(mx + 0.5, my + 0.5) then
    drawingArea.fillStyle('rgb(192,1000,192)')
  else
    drawingArea.fillStyle('rgb(0,1000,0)');
  drawingArea.fill();
  drawingArea.stroke();
  //Solid triangle with border
  UpdateIn(50);
end;

procedure Tform_1.Test4(drawingArea: TBGRACanvas2D; grainElapse: integer);
var
  angle: single;
  p0, p1, p2: TPointF;
begin
  Inc(test4pos, grainElapse);
  angle := test4pos * 2 * Pi / 400;
  drawingArea.translate((drawingArea.Width - 300) / 2, (drawingArea.Height - 300) / 2);
  drawingArea.skewx(sin(angle));

  drawingArea.beginPath;
  drawingArea.rect(0, 0, 300, 300);
  drawingArea.fillStyle(CSSYellow);
  drawingArea.strokeStyle(CSSRed);
  drawingArea.lineWidth := 5;
  drawingArea.strokeOverFill;

  drawingArea.beginPath();
  // coord. centre 150,150  radius : 50 starting angle 0 end 2Pi
  drawingArea.arc(150, 150, 50, 0, PI * 2, True); // Cercle
  drawingArea.moveTo(100, 150); // go to the starting point of the arc
  drawingArea.arc(100, 100, 50, PI / 2, PI, False); // Arc sens aig. montre
  drawingArea.moveTo(150, 150); // go to the starting point of the arc
  drawingArea.arc(200, 150, 50, 2 * PI / 2, 0, False);  // Autre cercle
  drawingArea.lineWidth := 1;
  drawingArea.strokeStyle(BGRABlack);
  drawingArea.stroke();

  drawingArea.lineJoin := 'round';

  angle := test4pos * 2 * Pi / 180;
  p0 := PointF(150, 50);
  p1 := pointF(150 + 50, 50);
  p2 := pointF(150 + 50 + cos(sin(angle) * Pi / 2) * 40, 50 +
    sin(sin(angle) * Pi / 2) * 40);
  drawingArea.beginPath;
  drawingArea.moveTo(p0);
  drawingArea.arcTo(p1, p2, 30);
  drawingArea.lineTo(p2);
  drawingArea.lineWidth := 5;
  drawingArea.strokeStyle(BGRA(240, 170, 0));
  drawingArea.stroke();

  drawingArea.beginPath;
  drawingArea.moveTo(p0);
  drawingArea.lineTo(p1);
  drawingArea.lineTo(p2);
  drawingArea.strokeStyle(BGRA(0, 0, 255));
  drawingArea.lineWidth := 2;
  drawingArea.stroke();

  UpdateIn(10);
end;

procedure Tform_1.Test5(drawingArea: TBGRACanvas2D; grainElapse: integer);
var
  svg: TBGRASVG;
begin
  Inc(test5pos, grainElapse);

  svg := TBGRASVG.Create;
  svg.LoadFromFile(gvars.path_media_s + 'Amsterdammertje-icoon.svg');
  svg.StretchDraw(drawingArea, taCenter, tlCenter, 0, 0, drawingArea.Width /
    3, drawingArea.Height);

  svg.LoadFromFile(gvars.path_media_s + 'BespectacledMaleUser.svg');
  svg.StretchDraw(drawingArea, drawingArea.Width / 3, 0, drawingArea.Width *
    2 / 3, drawingArea.Height / 2);

  drawingArea.save;
  drawingArea.beginPath;
  drawingArea.rect(drawingArea.Width / 3, drawingArea.Height / 2,
    drawingArea.Width * 2 / 3, drawingArea.Height / 2);
  drawingArea.clip;
  svg.LoadFromFile(gvars.path_media_s + 'Blue_gyroelongated_pentagonal_pyramid.svg');
  svg.Draw(drawingArea, taCenter, tlCenter, drawingArea.Width * 2 /
    3, drawingArea.Height * 3 / 4);
  drawingArea.restore;

  svg.Free;

  drawingArea.beginPath;
  drawingArea.lineWidth := 1;
  drawingArea.strokeStyle(BGRABlack);
  drawingArea.moveTo(drawingArea.Width / 3, 0);
  drawingArea.lineTo(drawingArea.Width / 3, drawingArea.Height);
  drawingArea.moveTo(drawingArea.Width / 3, drawingArea.Height / 2);
  drawingArea.lineTo(drawingArea.Width, drawingArea.Height / 2);
  drawingArea.stroke;

  UpdateIn(20);
end;

procedure Tform_1.Test6(drawingArea: TBGRACanvas2D);
begin
  drawingArea.fillStyle('rgb(1000,1000,1000)');
  drawingArea.fillRect(0, 0, 300, 300);
  //Example of Bézier curves
  drawingArea.fillStyle('yellow');
  drawingArea.lineWidth := 15;
  drawingArea.lineCap := 'round'; //round butt square
  drawingArea.lineJoin := 'miter'; //round miter bevel
  drawingArea.strokeStyle('rgb(200,200,1000)');
  drawingArea.beginPath();
  drawingArea.moveTo(50, 150);
  drawingArea.bezierCurveTo(50, 80, 100, 60, 130, 60);
  drawingArea.bezierCurveTo(180, 60, 250, 50, 260, 130);
  drawingArea.bezierCurveTo(150, 150, 150, 150, 120, 280);
  drawingArea.bezierCurveTo(50, 250, 100, 200, 50, 150);
  drawingArea.fill();
  drawingArea.stroke();
end;

procedure Tform_1.Test7(drawingArea: TBGRACanvas2D);
var
  i: integer;
begin
  drawingArea.fillStyle('black');
  drawingArea.fillRect(0, 0, 300, 300);
  // Background drawing
  drawingArea.fillStyle('red');
  drawingArea.fillRect(0, 0, 150, 150);
  drawingArea.fillStyle('blue');
  drawingArea.fillRect(150, 0, 150, 150);
  drawingArea.fillStyle('yellow');
  drawingArea.fillRect(0, 150, 150, 150);
  drawingArea.fillStyle('green');
  drawingArea.fillRect(150, 150, 150, 150);
  drawingArea.fillStyle('#FFF');
  //Definition of the transparency value
  drawingArea.globalAlpha := 0.1;
  //Drawing of semi-transparent squares
  for i := 0 to 9 do
  begin
    drawingArea.beginPath();
    drawingArea.fillRect(10 * i, 10 * i, 300 - 20 * i, 300 - 20 * i);
    drawingArea.fill();
  end;
end;

procedure Tform_1.Test8(drawingArea: TBGRACanvas2D);
begin
  drawingArea.drawImage(img, 0, 0);
  drawingArea.globalAlpha := 0.5;
  drawingArea.drawImage(img, 100, 100);
  drawingArea.globalAlpha := 0.9;
  drawingArea.translate(100, 100);
  drawingArea.beginPath;
  drawingArea.moveTo(50, 50);
  drawingArea.lineTo(300, 50);
  drawingArea.lineTo(500, 200);
  drawingArea.lineTo(50, 200);
  drawingArea.fillStyle(img);
  drawingArea.fill;
end;

procedure Tform_1.Test9(drawingArea: TBGRACanvas2D);
var
  i: integer;
  j: integer;
begin
  drawingArea.translate(drawingArea.Width / 2 - 15 * 10, drawingArea.Height /
    2 - 15 * 10);
  drawingArea.strokeStyle('#000');
  drawingArea.lineWidth := 4;
  for i := 0 to 14 do
    for j := 0 to 14 do
    begin
      drawingArea.fillStyle(BGRA(255 - 18 * i, 255 - 18 * j, 0));
      drawingArea.strokeStyle(BGRA(20 + 10 * j, 20 + 8 * i, 0));
      drawingArea.fillRect(j * 20, i * 20, 20, 20);
      drawingArea.strokeRect(j * 20, i * 20, 20, 20);
    end;
end;

procedure Tform_1.Test10(drawingArea: TBGRACanvas2D);
var
  i: integer;
  j: integer;
begin
  drawingArea.translate(drawingArea.Width / 2, drawingArea.Height / 2);
  //center 0 0 now in central position
  for i := 1 to 9 do
  begin
    drawingArea.save(); // counterbalanced by a restore
    drawingArea.fillStyle(BGRA(25 * i, 255 - 25 * i, 255));
    for j := 0 to i * 5 do
    begin
      drawingArea.rotate(PI * 2 / (1 + i * 5));
      drawingArea.beginPath();
      drawingArea.arc(0, i * 16, 6, 0, PI * 2, True);
      drawingArea.fill();
    end;
    drawingArea.restore();
  end;
end;

procedure Tform_1.Test11(drawingArea: TBGRACanvas2D);
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
  H := drawingArea.Height;
  W := drawingArea.Width;
  // grid layout
  drawingArea.strokeStyle('#666');
  drawingArea.beginPath();
  drawingArea.lineWidth := 0.5;
  //horizontal lines
  for i := -trunc(H / 2 / sc) to trunc(H / 2 / sc) do
  begin
    drawingArea.moveTo(0, H / 2 - sc * i);
    drawingArea.lineTo(W, H / 2 - sc * i);
  end;
  // vertical lines
  for i := 0 to trunc(W / sc) do
  begin
    drawingArea.moveTo(sc * i, H - 0);
    drawingArea.lineTo(sc * i, H - H);
  end;
  drawingArea.stroke();
  //function plot
  drawingArea.strokeStyle('#ff0000');
  drawingArea.lineWidth := 1.5;
  drawingArea.beginPath();
  x := 0;
  u := f(x);
  drawingArea.moveTo(0, H / 2 - u * sc);
  while x < W / sc do
  begin
    u := f(x);
    drawingArea.lineTo(x * sc, H / 2 - u * sc);
    x += 1 / sc;
  end;
  drawingArea.stroke();
end;

procedure Tform_1.Test12(drawingArea: TBGRACanvas2D);
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
    drawingArea.beginPath();
    x1 := x0;
    y1 := y0;
    drawingArea.moveTo(x1, y1);
    repeat
      if (i > 1000) then
        break;
      x2 := (R2 + r) * cos(i * PI / 72) - (r + O) * cos(((R2 + r) / r) * (i * PI / 72));
      y2 := (R2 + r) * sin(i * PI / 72) - (r + O) * sin(((R2 + r) / r) * (i * PI / 72));
      drawingArea.lineTo(x2, y2);
      x1 := x2;
      y1 := y2;
      Inc(i);
    until (abs(x2 - x0) < 1e-6) and (abs(y2 - y0) < 1e-6);
    drawingArea.stroke();
  end;

begin
  W := drawingArea.Width;
  H := drawingArea.Height;
  drawingArea.fillRect(0, 0, W, H);
  for i := 0 to 1 do
    for j := 0 to 2 do
    begin
      drawingArea.save();
      drawingArea.strokeStyle(color());
      drawingArea.translate(110 + j * 200, 100 + i * 160);
      drawSpirograph(40 * (j + 2) / (j + 1), -(3 + random(11)) * (i + 3) / (i + 1), 35);
      drawingArea.restore();
    end;

  UpdateIn(3000);
end;

procedure Tform_1.Test13(drawingArea: TBGRACanvas2D);
const
  vitesse = 1;
begin
  drawingArea.fillStyle('#000');
  drawingArea.fillRect(0, 0, 800, 400);
  drawingArea.clearRect(0, 0, 800, 400);
  drawingArea.fillRect(0, 0, 800, 400);
  drawingArea.setTransform(-0.55, 0.85, -1, 0.10, 100, 50 + img.Width * 0.5);
  drawingArea.rotate(PI * 2 * (Test13pos / 360) * vitesse);
  drawingArea.drawImage(img, img.Width * (-0.5) - 200, img.Height * (-0.8));
  Test13pos += 1;
  if (Test13pos = 360) then
    Test13pos := 0;
  UpdateIn(10);
end;

procedure Tform_1.Test14(drawingArea: TBGRACanvas2D);

  procedure pave();
  begin
    drawingArea.save();
    drawingArea.fillStyle('rgb(130,100,800)');
    drawingArea.strokeStyle('rgb(0,0,300)');
    drawingArea.beginPath();
    drawingArea.lineWidth := 2;
    drawingArea.moveTo(5, 5);
    drawingArea.lineTo(20, 10);
    drawingArea.lineTo(55, 5);
    drawingArea.lineTo(45, 18);
    drawingArea.lineTo(30, 50);
    drawingArea.closePath();
    drawingArea.stroke();
    drawingArea.fill();
    drawingArea.fillStyle('rgb(300,300,100)');
    drawingArea.lineWidth := 5;
    drawingArea.strokeStyle('rgb(0,300,0)');
    drawingArea.beginPath();
    drawingArea.moveTo(20, 18);
    drawingArea.lineTo(40, 16);
    drawingArea.lineTo(35, 26);
    drawingArea.lineTo(25, 30);
    drawingArea.closePath();
    drawingArea.stroke();
    drawingArea.fill();
    drawingArea.restore();
  end;
  //drawings of a hexagon from six pavers by rotation
  procedure six();
  var
    i: integer;
  begin
    drawingArea.save();
    for i := 0 to 5 do
    begin
      drawingArea.rotate(2 * PI / 6);
      pave();
    end;
    drawingArea.restore();
  end;
  //tiling using translations according to two non-collinear vectors
  // 0,60*Math.sqrt(3)     et     60*3/2, 60*Math.sqrt(3)/2
  procedure draw();
  var
    i: integer;
    j: integer;
  begin
    drawingArea.fillStyle('rgb(800,100,50)');
    drawingArea.fillRect(0, 0, drawingArea.Width, drawingArea.Height);
    for j := 0 to (drawingArea.Width + 60) div 90 do
    begin
      drawingArea.save();
      drawingArea.translate(0, (-j div 2) * 60 * sqrt(3));
      for i := 0 to round(drawingArea.Height / (60 * sqrt(3))) do
      begin
        six();
        drawingArea.translate(0, 60 * sqrt(3));
      end;

      drawingArea.restore();
      drawingArea.translate(90, sqrt(3) * 60 / 2);
    end;
  end;

begin
  draw();
end;

procedure Tform_1.Test15(drawingArea: TBGRACanvas2D);
const
  cote = 190;

  procedure pave();
  begin
    drawingArea.drawImage(abelias, 0, 0);
  end;

  procedure refl();
  begin
    drawingArea.save();
    pave();
    drawingArea.transform(1, 0, 0, -1, 0, 0);
    pave();
    drawingArea.restore();
  end;

  //drawings of a hexagon from six pavers by rotation
  procedure trois();
  var
    i: integer;
  begin
    drawingArea.save();
    for i := 0 to 2 do
    begin
      drawingArea.rotate(4 * PI / 6);
      refl();
    end;
    drawingArea.restore();
  end;

  // tiling using translations according to two non-collinear vectors
  // 0,cote*Math.sqrt(3)     et     cote*3/2, cote*Math.sqrt(3)/2
  procedure draw();
  var
    i: integer;
    j: integer;
  begin
    drawingArea.fillStyle('#330055');
    drawingArea.fillRect(0, 0, drawingArea.Width, drawingArea.Height);
    drawingArea.translate(140, 140);
    for j := 0 to trunc(drawingArea.Width / (cote * 3 / 2)) do
    begin
      drawingArea.save();
      drawingArea.translate(0, -(1 / 2 + j div 2) * cote * sqrt(3));
      for i := 0 to trunc(drawingArea.Height / (cote * sqrt(3))) + 1 do
      begin
        trois();
        drawingArea.translate(0, cote * sqrt(3));
      end;
      drawingArea.restore();
      drawingArea.translate(cote * 3 / 2, sqrt(3) * cote / 2);
    end;
  end;

begin
  draw();
end;

procedure Tform_1.Test16(drawingArea: TBGRACanvas2D; grainElapse: integer);
var
  center: TPointF;
  angle, zoom: single;
begin
  Inc(test16pos, grainElapse);
  center := pointf(drawingArea.Width / 2, drawingArea.Height / 2);
  angle := test16pos * 2 * Pi / 300;
  zoom := (sin(test16pos * 2 * Pi / 400) + 1.1) *
    min(drawingArea.Width, drawingArea.Height) / 300;
  with drawingArea do
  begin
    translate(center.X, center.Y);
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

procedure Tform_1.Test17(drawingArea: TBGRACanvas2D; grainElapse: integer);
var
  grad: IBGRACanvasGradient2D;
  angle: single;
begin
  Inc(test17pos, grainElapse);
  angle := test17pos * 2 * Pi / 1000;

  drawingArea.translate(drawingArea.Width / 2, drawingArea.Height / 2);
  drawingArea.scale(min(drawingArea.Width, drawingArea.Height) / 2 - 10);
  drawingArea.rotate(angle);

  grad := drawingArea.createLinearGradient(-1, -1, 1, 1);
  grad.addColorStop(0.3, '#ff0000');
  grad.addColorStop(0.6, '#0000ff');
  drawingArea.fillStyle(grad);

  grad := drawingArea.createLinearGradient(-1, -1, 1, 1);
  grad.addColorStop(0.3, '#ffffff');
  grad.addColorStop(0.6, '#000000');
  drawingArea.strokeStyle(grad);
  drawingArea.lineWidth := 5;

  drawingArea.beginPath;
  drawingArea.moveto(0, 0);
  drawingArea.arc(0, 0, 1, Pi / 6, -Pi / 6, False);
  drawingArea.fill();
  drawingArea.stroke();

  UpdateIn(10);
end;

procedure Tform_1.Test18(drawingArea: TBGRACanvas2D; grainElapse: integer);
var
  pat: TBGRABitmap;
begin
  Inc(test18pos, grainElapse);
  drawingArea.translate(drawingArea.Width div 2, drawingArea.Height div 2);
  drawingArea.rotate(test18pos * 2 * Pi / 360);
  drawingArea.scale(3, 3);
  pat := TBGRABitmap.Create(8, 8);
  pat.GradientFill(0, 0, 8, 8, BGRABlack, BGRAWhite, gtLinear,
    PointF(0, 0), PointF(8, 8), dmSet);
  //  drawingArea.surface.CreateBrushTexture(bsDiagCross,BGRA(255,255,0),BGRA(255,0,0)) as TBGRABitmap;
  drawingArea.fillStyle(drawingArea.createPattern(pat, 'repeat-x'));
  drawingArea.fillRect(0, 0, drawingArea.Width, pat.Height - 1);
  drawingArea.fillStyle(drawingArea.createPattern(pat, 'repeat-y'));
  drawingArea.fillRect(0, 0, pat.Width - 1, drawingArea.Height);

  drawingArea.rotate(Pi);
  drawingArea.globalAlpha := 0.25;
  drawingArea.fillStyle(drawingArea.createPattern(pat, 'repeat-x'));
  drawingArea.fillRect(0, 0, drawingArea.Width, drawingArea.Height);
  drawingArea.fillStyle(drawingArea.createPattern(pat, 'repeat-y'));
  drawingArea.fillRect(0, 0, drawingArea.Width, drawingArea.Height);
  pat.Free;

  UpdateIn(10);
end;

procedure Tform_1.Test19(drawingArea: TBGRACanvas2D; grainElapse: integer);
var
  i: integer;
  tx, ty: single;
begin
  Inc(test19pos, grainElapse);
  drawingArea.save;
  drawingArea.translate(drawingArea.Width div 2, drawingArea.Height div 2);
  drawingArea.rotate(test19pos * 2 * Pi / 500);
  drawingArea.scale(drawingArea.Height / 2, drawingArea.Height / 2);
  drawingArea.beginPath;
  drawingArea.moveto(1, 0);
  for i := 1 to 8 do
  begin
    drawingArea.rotate(2 * Pi / 8);
    drawingArea.lineto(1, 0);
  end;
  drawingArea.restore;
  drawingArea.clip;

  tx := drawingArea.Width div 2;
  ty := drawingArea.Height div 2;
  drawingArea.fillStyle('red');
  drawingArea.fillRect(0, 0, tx, ty);
  drawingArea.fillStyle('blue');
  drawingArea.fillRect(tx, 0, tx, ty);

  drawingArea.globalAlpha := 0.75;
  drawingArea.fillStyle('yellow');
  drawingArea.fillRect(0, ty, tx, ty);
  drawingArea.fillStyle('green');
  drawingArea.fillRect(tx, ty, tx, ty);

  test18(drawingArea, grainElapse);
end;

procedure Tform_1.Test20(drawingArea: TBGRACanvas2D; AVectorizedFont: boolean);
var
  i: integer;
  grad: IBGRACanvasGradient2D;
begin
  UseVectorizedFont(drawingArea, AVectorizedFont);
  drawingArea.save;

  drawingArea.fontName := 'default';
  drawingArea.fontEmHeight := drawingArea.Height / 10;
  drawingArea.textBaseline := 'alphabetic';

  drawingArea.beginPath;
  if AVectorizedFont then
    drawingArea.Text('Vectorized font', drawingArea.fontEmHeight *
      0.2, drawingArea.fontEmHeight)
  else
    drawingArea.Text('Raster font', drawingArea.fontEmHeight * 0.2,
      drawingArea.fontEmHeight);
  drawingArea.lineWidth := 2;
  drawingArea.strokeStyle(clLime);
  drawingArea.fillStyle(clBlack);
  drawingArea.fillOverStroke;

  grad := drawingArea.createLinearGradient(0, 0, drawingArea.Width, drawingArea.Height);
  grad.addColorStop(0.3, '#000080');
  grad.addColorStop(0.7, '#00a0a0');
  drawingArea.fillStyle(grad);

  drawingArea.translate(drawingArea.Width / 2, drawingArea.Height / 2);

  for i := 0 to 11 do
  begin
    drawingArea.beginPath;
    drawingArea.moveTo(0, 0);
    drawingArea.lineTo(drawingArea.Width + drawingArea.Height, 0);
    drawingArea.strokeStyle(clRed);
    drawingArea.lineWidth := 1;
    drawingArea.stroke;

    drawingArea.beginPath;
    drawingArea.Text('hello', drawingArea.Width / 10, 0);
    drawingArea.fill;
    drawingArea.rotate(Pi / 6);
  end;
  drawingArea.restore;
  drawingArea.fontRenderer := nil;
end;

procedure Tform_1.Test22(drawingArea: TBGRACanvas2D);
var
  layer: TBGRABitmap;
begin
  layer := TBGRABitmap.Create(drawingArea.Width, drawingArea.Height, CSSRed);
  with layer.Canvas2D do
  begin
    pixelCenteredCoordinates := drawingArea.pixelCenteredCoordinates;
    antialiasing := drawingArea.antialiasing;
    fontName := 'default';
    fontStyle := [fsBold];
    fontEmHeight := min(drawingArea.Height / 2, drawingArea.Width / 4);
    textBaseline := 'middle';
    textAlign := 'center';

    beginPath;
    Text('hole', Width / 2, Height / 2);
    clearPath;
  end;
  drawingArea.surface.DrawCheckers(rect(0, 0, drawingArea.Width, drawingArea.Height),
    CSSWhite, CSSSilver);
  drawingArea.surface.PutImage(0, 0, layer, dmDrawWithTransparency);
end;

procedure Tform_1.Test23(drawingArea: TBGRACanvas2D; grainElapse: integer);
begin
  UseVectorizedFont(drawingArea, True);
  with drawingArea do
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

procedure Tform_1.Test24(drawingArea: TBGRACanvas2D);
var
  colors: TBGRACustomGradient;
  {rationalbezier}Center: TPoint;  f: TBGRACanvas2D; R, boundsF: TrectF;
  Aleft, Aright : TRationalQuadraticBezierCurve; precision: single;
  B, B2: TRationalQuadraticBezierCurve; {/rationalbezier}
begin
  B:=BezierCurve(PointF(150,180), PointF(0,0), PointF(150,80), 2.0);
  B2:=BezierCurve(PointF(150,180), PointF(0,0), PointF(150,80), -2.0);
  if (mx < 0) or (my < 0) then
  begin
    mx := drawingArea.Width div 2;
    my := drawingArea.Height div 2;
  end;
  drawingArea.fillStyle('rgb(61,112,150)');
  drawingArea.fillRect(0, 0, drawingArea.Width, drawingArea.Height);


  {rationalbezier}
   precision := 0.40;//FloatSpinEdit2.Value;
  //Img.SetSize(ClientWidth,ClientHeight-Panel1.Height);
  //Img.Fill(clWhite);
  //f := Img.Canvas2D;
  Center := Point(ClientWidth div 2, ClientWidth div 2);
  boundsF := RectF(0,0, Img.Width,Img.Height);
  boundsF.Offset(-Center.X, -Center.Y);
  f := Img.Canvas2D;
  f.resetTransform;
  f.translate(Center.X,Center.Y);
  f.lineJoinLCL:= pjsBevel;
  // arc d'ellipse en rouge, poids 0.4 (petit arc)
  drawingArea.beginPath;
  drawingArea.moveto(B.p1);
  drawingArea.lineTo(B.c);
  drawingArea.lineTo(B.p2);
  drawingArea.moveto(B2.p1);
  drawingArea.lineTo(B2.c);
  drawingArea.lineTo(B2.p2);
  drawingArea.moveto(B.p1.x+5,B.p1.y);
  drawingArea.circle(B.p1.x,B.p1.y,5);
  drawingArea.moveto(B.c.x+5,B.c.y);
  drawingArea.circle(B.c.x,B.c.y,5);
  drawingArea.moveto(B.p2.x+5,B.p2.y);
  drawingArea.circle(B.p2.x,B.p2.y,5);
  drawingArea.strokeStyle(clblack);
  drawingArea.linewidth := 1;
  drawingArea.stroke();
  drawingArea.beginPath;
  drawingArea.lineWidth := 4;
  drawingArea.strokeStyle(BGRA(255,0,96,255));
  drawingArea.moveTo(B.p1);
  drawingArea.polylineTo(B.ToPoints(boundsF,precision));
  drawingArea.stroke();
  // arc d'ellipse en vert, poids -0.4 (grand arc, complétant le précédent)
  drawingArea.beginPath;
  drawingArea.strokeStyle(BGRA(96,160,0,255));
  drawingArea.polylineTo(B2.ToPoints(boundsF,precision));
  drawingArea.stroke();
  // arc d'ellipse en vert, poids -0.4 (grand arc, complétant le précédent)
 drawingArea.beginPath;
 drawingArea.strokeStyle(BGRA(96,160,0,255));
 drawingArea.polylineTo(B2.ToPoints(boundsF,precision));
 drawingArea.stroke();
  if not B2.IsInfinite then
    begin
      // arc en bleu, c'est la deuxième moitié de l'arc en vert
      B2.Split(Aleft, Aright);
      drawingArea.strokeStyle(BGRA(0,96,255,255));
      drawingArea.beginPath;
      drawingArea.moveTo(Aright.p1);
      drawingArea.polylineTo(Aright.ToPoints(boundsF,precision*2));
      drawingArea.stroke;

      // bounding box de l'arc en vert
      R:=B2.GetBounds();
      drawingArea.beginPath;
      drawingArea.rect(round(R.Left)-1, round(R.Top)-1, round(R.Width)+2, round(R.Height)+2);
      drawingArea.strokeStyle(BGRABlack);
      drawingArea.lineWidth := 1;
      drawingArea.stroke();
    end;
    Img.draw(Canvas,0,50);
  {/rationalbezier}


end;




end.

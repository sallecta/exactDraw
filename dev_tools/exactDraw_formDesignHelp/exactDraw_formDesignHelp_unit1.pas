unit exactDraw_formDesignHelp_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  StdCtrls, Spin, PairSplitter, LvlGraphCtrl, DividerBevel;

type

  { TForm1 }

  TForm1 = class(TForm)
    Btn_toDataURL: TButton;
    ChBox_pixCentered: TCheckBox;
    ChBx_Antialias: TCheckBox;
    Memo_dbg: TMemo;
    Panel1: TPanel;
    Pnl_1: TPanel;
    SpinEd_1: TSpinEdit;
    VScr_Area: TPanel;
    procedure ControlBar1Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure Pnl_1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.MenuItem1Click(Sender: TObject);
begin

end;

procedure TForm1.Pnl_1Click(Sender: TObject);
begin

end;

procedure TForm1.ControlBar1Click(Sender: TObject);
begin

end;

end.


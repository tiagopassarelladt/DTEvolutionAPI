unit UqrCodeEvo;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  System.IOUtils, RespConnectionState, Vcl.ComCtrls;

type
  TFrmqrCodeEvo = class(TForm)
    Image1: TImage;
    Button2: TButton;
    pnStatus: TPanel;
    pbPIX: TProgressBar;
    Timer1: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FRespConnectionState: TRespConnectionState;
    FKey: string;
    FBaseURL: string;
    FInstancia: string;

  public

  published
   property RespConnectionState : TRespConnectionState read FRespConnectionState write FRespConnectionState;
   property BaseURL             : string               read FBaseURL             write FBaseURL;
   property Key                 : string               read FKey                 write FKey;
   property Instancia           : string               read FInstancia           write FInstancia;


  end;

var
  FrmqrCodeEvo: TFrmqrCodeEvo;

implementation

uses
  ConnectionState;

{$R *.dfm}

procedure TFrmqrCodeEvo.Button2Click(Sender: TObject);
Var
 Req : TConnectionState;
Begin

 Req    := TConnectionState.Create;
 Req.APIExecute(FBaseURL,FKey,FInstancia);

 FRespConnectionState := Req.RespConnectionState;

 FreeAndNil(Req);

 pnStatus.Caption := FRespConnectionState.instance.state;


 if UpperCase(FRespConnectionState.instance.state) = 'OPEN' then
   CLOSE;
end;

procedure TFrmqrCodeEvo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action       := caFree;
  FrmqrCodeEvo := nil;
end;

procedure TFrmqrCodeEvo.Timer1Timer(Sender: TObject);
begin
      pnStatus.Caption := 'Verificando';
      Button2Click(Sender);
end;

end.
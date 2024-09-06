unit DTEvolutionAPI;

interface

uses
  System.SysUtils,
  System.Classes,
  RespCreateInstance,
  RespInstanceConnect,
  system.NetEncoding,
  vcl.Imaging.pngimage,
  Soap.EncdDecd,
  Vcl.Forms,
  RespConnectionState,
  system.Net.HttpClient,
  RespSendText,
  UEmojisEvo,
  Vcl.ExtCtrls,
  Json,
  Winapi.Windows, RespContacts, System.Generics.Collections;

 type TVersaoAPI = (tpverAnteriores, tpver200, tpver201);

type

  TListaContatos = class
  private
    FId               : string;
    FOwner            : string;
    FProfilePictureUrl: string;
    FPushName         : string;
  public
    property id                : string read FId                write FId;
    property owner             : string read FOwner             write FOwner;
    property profilePictureUrl : string read FProfilePictureUrl write FProfilePictureUrl;
    property pushName          : string read FPushName          write FPushName;

  end;

type
  TDTEvolutionAPI = class(TComponent)
  private
    FBaseURL: string;
    FRetCreateInstance: TRespCreateInstance;
    FKey: string;
    FInstancia: string;
    FRespInstanceConnect: TRespInstanceConnect;
    FqrCode: TImage;
    FForm: TForm;
    FRespConnectionState: TRespConnectionState;
    FRespSendText: TRespSendText;
    FEmojiScrollBox: TScrollBox;
    FEmojiComponent: TComponent;
    FVersaoAPI: TVersaoAPI;


    procedure Base64ToImage(const Base64String: string;Owner: TComponent);
    procedure ClickEmoji(Sender : TObject);
    function GetTempDir: string;
    function FileToBase64(Arquivo: String): String;
    function StreamToBase64(STream: TMemoryStream): String;
    function DetectFileType(const filePath: string): string;
    procedure SetVersaoAPI(const Value: TVersaoAPI);
    function GetMimeType(const FileName: string): string;

  protected

  public
   ListaContatos:TList<TListaContatos>;
   function VersaoAPIFromString(const AStr: string): TVersaoAPI;
   // INSTANCIA
   function CreateInstance  : boolean;
   function fetchInstances  : boolean;
   function ConnectInstace  : boolean;
   function ConnectionState : Boolean;
   function LogoutInstance  : Boolean;
   function RestartInstance  : Boolean;
   function DeleteInstance  : Boolean;
   // MENSAGEM
   function SendText(Fone : string; Mensagem : string) : Boolean;
   function SendImagem(Fone, Mensagem, CaminhoIMG: string): Boolean;
   function SendDocument(Fone, Mensagem, CaminhoDOC: string): Boolean;
   // CARREGA EMOJIS
   function ListaEmojis : Boolean;
   // LISTA CONTATOS
   function ListContacts: Boolean;

   constructor Create(AOwner: TComponent); override;
   destructor Destroy; override;
  published
   property BaseURL   : string read FBaseURL   write FBaseURL;
   property Key       : string read FKey       write FKey;
   property Instancia : string read FInstancia write FInstancia;

   // instancia
   property RespCreateInstance : TRespCreateInstance  read FRetCreateInstance   write FRetCreateInstance;
   property RespInstanceConnect: TRespInstanceConnect read FRespInstanceConnect write FRespInstanceConnect;
   property RespConnectionState: TRespConnectionState read FRespConnectionState write FRespConnectionState;
   // mensagem
   property RespSendText       : TRespSendText        read FRespSendText        write FRespSendText;
   // emojis
   property EmojiScrollBox     : TScrollBox           read FEmojiScrollBox      write FEmojiScrollBox;
   // contacts

   property qrCode             : TImage               read FqrCode              write FqrCode;
   property Form               : TForm                read FForm                write FForm;
   property EmojiComponent     : TComponent           read FEmojiComponent      write FEmojiComponent;

   property VersaoAPI          : TVersaoAPI           read FVersaoAPI           write SetVersaoAPI;
  end;

procedure Register;

implementation

uses
  CreateInstance,

  fetchInstances, InstanceConnect, ConnectionState,
  System.Net.URLClient, SendText, Vcl.Controls, Vcl.StdCtrls, UqrCodeEvo,
  Contacts;

procedure Register;
begin
  RegisterComponents('DT Inovacao', [TDTEvolutionAPI]);
end;

{ TDTEvolutionAPI }

function TDTEvolutionAPI.VersaoAPIFromString(const AStr: string): TVersaoAPI;
begin
  if AStr = 'tpverAnteriores' then
    Result := tpverAnteriores
  else if AStr = 'tpver200' then
    Result := tpver200
  else if AStr = 'tpver201' then
    Result := tpver201
  else
    raise Exception.Create('Versão API desconhecida: ' + AStr);
end;

Function TDTEvolutionAPI.GetTempDir: string;
var
  Buffer: array[0..MAX_PATH] of Char;
begin
  SetString(Result, Buffer, GetTempPath(MAX_PATH, Buffer));
end;

function TDTEvolutionAPI.ListaEmojis: Boolean;
var
  I          : Integer;
  EmojiLabel : TLabel;
  emj        : TEmojisEvo;
begin
  emj := TEmojisEvo.Create;
  for I := 0 to Length(emj.EmojiList) - 1 do
  begin
    EmojiLabel             := TLabel.Create(Self);
    EmojiLabel.Parent      := FEmojiScrollBox; // assuming Panel1 is the name of your TPanel
    EmojiLabel.AutoSize    := true;
    EmojiLabel.Font.Name   := 'Segoe UI Emoji'; // Fonte que suporta emojis
    EmojiLabel.Font.Size   := 16;
    EmojiLabel.Caption     := emj.EmojiList[I];
    EmojiLabel.Left        := 10 + (I mod 11) * 40;
    EmojiLabel.Top         := 20 + (I div 11) * 30;
    EmojiLabel.OnClick     := ClickEmoji;
    FEmojiScrollBox.Cursor := crHandPoint;
  end;
  FreeAndNil(emj);

end;

function TDTEvolutionAPI.ListContacts: Boolean;
var
  HttpClient   : THttpClient;
  LResponse    : IHttpResponse;
  RequestBody  : TStringStream;
  xURL_EXECUTE : string;
  json         : String;
  xcont        : TListaContatos;
  obj,item     : TJSONObject;
  arr          : TJSONArray;
  i: Integer;
begin
    xURL_EXECUTE     := BaseURL + '/chat/findContacts/' + instancia;
    HttpClient       := THTTPClient.Create;
  try
     json :=
     ' { ' +
     ' "where": { ' +
     '  ' +
     ' } ' +
     ' } ';

    {Add Body}
    RequestBody := TStringStream.Create('',TEncoding.UTF8);

    LResponse   := HttpClient.Post( xURL_EXECUTE,
                                   RequestBody,nil,

      TNetHeaders.Create(

    {Add Headers}
      TNameValuePair.Create('apikey', key) ));

    Result := LResponse.StatusCode = 200;

    if not LResponse.StatusCode in [200,201] then
     raise Exception.Create( LResponse.ContentAsString );

     arr := TJSONArray.Create;
     obj := TJSONObject.ParseJSONValue('{"lista": ' + LResponse.ContentAsString + '}') as TJSONObject;
     arr := obj.GetValue('lista') as TJSONArray;

     ListaContatos.Clear;

     for i := 0 to Pred(arr.Count) do
     begin
          try
           item                     := arr.Items[i] as TJSONObject;
           xcont                    := TListaContatos.Create;
           xcont.FId                := item.GetValue('id').Value;
           xcont.FpushName          := item.GetValue('pushName').Value;
           xcont.FprofilePictureUrl := item.GetValue('profilePictureUrl').Value;
           xcont.FOwner             := item.GetValue('owner').Value;
          except
             if i=830 then
           json := json;
          end;



           ListaContatos.Add(xcont);
     end;

  except
    on E:Exception do
    begin
      Result := False;
      raise Exception.Create('Error Method TContacts.APIExecute'+ sLineBreak + E.Message);
    end;
  end;
end;

function TDTEvolutionAPI.LogoutInstance: Boolean;
var
  HttpClient   : THttpClient;
  LResponse    : IHttpResponse;
  RequestBody  : TStringStream;
  xURL_EXECUTE : string;
  json         : String;
begin

          xURL_EXECUTE           := BaseURL + '/instance/logout/' + FInstancia;
          HttpClient             := THTTPClient.Create;
          HttpClient.ContentType := 'application/json';

          try
              try
                {Add Body}
                RequestBody := TStringStream.Create(json);
                LResponse   := HttpClient.Delete( xURL_EXECUTE,
                                               nil,
                  TNetHeaders.Create(
                  TNameValuePair.Create('apikey', FKey)));

                Result := LResponse.StatusCode = 200;

                if not LResponse.StatusCode in [200,201] then
                 raise Exception.Create( LResponse.ContentAsString );

              except
                on E:Exception do
                begin
                  Result := false;
                  raise Exception.Create('Error Method TCreateInstance.APIExecute'+ sLineBreak + E.Message);
                end;
              end;
          finally
              FreeAndNil(HttpClient);
              FreeAndNil(RequestBody);
          end;
end;

function TDTEvolutionAPI.RestartInstance: Boolean;
var
  HttpClient   : THttpClient;
  LResponse    : IHttpResponse;
  RequestBody  : TStringStream;
  xURL_EXECUTE : string;
  json         : String;
begin

          xURL_EXECUTE           := BaseURL + '/instance/restart/' + FInstancia;
          HttpClient             := THTTPClient.Create;
          HttpClient.ContentType := 'application/json';
          try

              try
                {Add Body}
                RequestBody := TStringStream.Create('');
                LResponse   := HttpClient.Put( xURL_EXECUTE, RequestBody,
                                               nil,
                  TNetHeaders.Create(
                  TNameValuePair.Create('apikey', FKey)));

                Result := LResponse.StatusCode = 200;

                if not LResponse.StatusCode in [200,201] then
                 raise Exception.Create( LResponse.ContentAsString );

              except
                on E:Exception do
                begin
                  Result := false;
                  raise Exception.Create('Error Method TCreateInstance.APIExecute'+ sLineBreak + E.Message);
                end;
              end;
          finally
             FreeAndNil(HttpClient);
             FreeAndNil(RequestBody);
          end;

end;

function TDTEvolutionAPI.StreamToBase64(STream: TMemoryStream): String;
Var Base64 : tBase64Encoding;
begin
  Try
    Stream.Position := 0; {ANDROID 64 e 32 Bits}
//    Stream.Seek(0, 0); {ANDROID 32 Bits}
    Base64 := TBase64Encoding.Create;
    Result := Base64.EncodeBytesToString(sTream.Memory, sTream.Size);
  Finally
    Base64.Free;
    Base64:=nil;
  End;
end;

function TDTEvolutionAPI.FileToBase64(Arquivo : String): String;
Var sTream : tMemoryStream;
begin
  if (Trim(Arquivo) <> '') then
  begin
     sTream := TMemoryStream.Create;
     Try
       sTream.LoadFromFile(Arquivo);
       result := StreamToBase64(sTream);
     Finally
       Stream.Free;
       Stream:=nil;
     End;
  end else
     result := '';
end;

function TDTEvolutionAPI.DetectFileType(const filePath: string): string;
var
  fileExt: string;
begin
  // Extrai a extensão do arquivo a partir do caminho do arquivo
  fileExt := LowerCase(ExtractFileExt(filePath));

  // Verifica a extensão e associa a um tipo
  if (fileExt = '.pdf') or (fileExt = '.doc') or (fileExt = '.docx') or (fileExt = '.txt') then
    Result := 'document'
  else if (fileExt = '.jpg') or (fileExt = '.jpeg') or (fileExt = '.png') or (fileExt = '.gif') then
    Result := 'image'
  else if (fileExt = '.mp3') or (fileExt = '.wav') or (fileExt = '.ogg') then
    Result := 'audio'
  else if (fileExt = '.zip') or (fileExt = '.rar') then
    Result := 'document'
  else
    Result := 'document'; // Tipo desconhecido
end;


function TDTEvolutionAPI.SendDocument(Fone, Mensagem,
  CaminhoDOC: string): Boolean;
var
  HttpClient   : THttpClient;
  LResponse    : IHttpResponse;
  RequestBody  : TStringStream;
  xURL_EXECUTE : string;
  json         : String;
  imgB64       : string;
begin
     if ConnectionState then
     begin
          imgB64 := StringReplace(FileToBase64(CaminhoDOC), #$D#$A, '', [rfReplaceAll]);
          if FVersaoAPI = tpverAnteriores then
          begin
              json  :=
              ' { '  +
              ' "number": "'+Fone+'", '  +
              ' "options": { '  +
              ' "delay": 1200, '  +
              ' "presence": "composing" '  +
              ' }, '  +
              ' "mediaMessage": { '  +
              ' "mediatype": "'+DetectFileType(CaminhoDOC)+'", '  +
              ' "fileName": "'+ ExtractFileName(CaminhoDOC) +'", ' +
              ' "caption": "'+UTF8Encode(StringReplace(StringReplace(Mensagem, #$D#$A,'\n', [rfReplaceAll]),#$A,'\n',[rfReplaceAll])) +'", '  +
              ' "media": "'+ imgB64 +'" } '  +
              ' } ';
          end;

          if FVersaoAPI in [tpver200,tpver201] then
          begin
              json  :=
                ' { '  +
                ' "number": "'+Fone+'", '  +
                ' "mediatype": "'+DetectFileType(CaminhoDOC)+'", '  +
                ' "mimetype": "'+ GetMimeType(ExtractFileName(CaminhoDOC)) +'", ' +
                ' "caption": "'+UTF8Encode(StringReplace(StringReplace(Mensagem, #$D#$A,'\n', [rfReplaceAll]),#$A,'\n',[rfReplaceAll])) +'", '  +
                ' "media": "'+ imgB64 +'", '  +
                ' "fileName": "'+ ExtractFileName(CaminhoDOC) +'" ' +
                ' } ';
          end;

          xURL_EXECUTE           := BaseURL + '/message/sendMedia/' + FInstancia;
          HttpClient             := THTTPClient.Create;
          HttpClient.ContentType := 'application/json';
          HttpClient.Accept      := '*/*';
          HttpClient.AcceptEncoding := 'gzip, deflate, br';
          try

            try
              {Add Body}
              RequestBody := TStringStream.Create(json,TEncoding.UTF8);
              LResponse   := HttpClient.Post( xURL_EXECUTE,RequestBody,
                                             nil,
                TNetHeaders.Create(
                TNameValuePair.Create('apikey', FKey)));

              Result := LResponse.StatusCode = 201;

              if not LResponse.StatusCode in [200,201] then
               raise Exception.Create( LResponse.ContentAsString );

            except
              on E:Exception do
              begin
                Result := false;
                raise Exception.Create('Error Method TCreateInstance.APIExecute'+ sLineBreak + E.Message);
              end;
            end;
          finally
            FreeAndNil(HttpClient);
            FreeAndNil(RequestBody);
          end;
     END else BEGIN
          CreateInstance;
     end;
end;

function TDTEvolutionAPI.SendImagem(Fone, Mensagem, CaminhoIMG: string): Boolean;
var
  HttpClient   : THttpClient;
  LResponse    : IHttpResponse;
  RequestBody  : TStringStream;
  xURL_EXECUTE : string;
  json         : String;
  imgB64       : string;
begin
     if ConnectionState then
     begin
          imgB64 := StringReplace(FileToBase64(CaminhoIMG), #$D#$A, '', [rfReplaceAll]);

          if FVersaoAPI = tpverAnteriores then
          begin
                json  :=
                ' { '  +
                ' "number": "'+Fone+'", '  +
                ' "options": { '  +
                ' "delay": 1200, '  +
                ' "presence": "composing" '  +
                ' }, '  +
                ' "mediaMessage": { '  +
                ' "mediatype": "image", '  +
                ' "caption": "'+UTF8Encode(StringReplace(StringReplace(Mensagem, #$D#$A,'\n', [rfReplaceAll]),#$A,'\n',[rfReplaceAll])) +'", '  +
                ' "media": "'+ imgB64 +'" } '  +
                ' } ';
          end;

          if FVersaoAPI in [ tpver200, tpver201 ] then
          begin
             json  :=
                ' { '  +
                ' "number": "'+Fone+'", '  +
                ' "mediatype": "image", '  +
                ' "mimetype": "'+ GetMimeType(ExtractFileName(CaminhoIMG)) +'", ' +
                ' "caption": "'+UTF8Encode(StringReplace(StringReplace(Mensagem, #$D#$A,'\n', [rfReplaceAll]),#$A,'\n',[rfReplaceAll])) +'", '  +
                ' "media": "'+ imgB64 +'", '  +
                ' "fileName": "'+ ExtractFileName(CaminhoIMG) +'" ' +
                ' } ';
          end;

          xURL_EXECUTE           := BaseURL + '/message/sendMedia/' + FInstancia;
          HttpClient             := THTTPClient.Create;
          HttpClient.ContentType := 'application/json; charset=utf-8';
          HttpClient.Accept      := '*/*';
          HttpClient.AcceptEncoding := 'gzip, deflate, br';
          try

            try
              {Add Body}
              RequestBody := TStringStream.Create(json,TEncoding.UTF8);
              LResponse   := HttpClient.Post( xURL_EXECUTE,RequestBody,
                                             nil,
                TNetHeaders.Create(
                TNameValuePair.Create('apikey', FKey)));

              Result := LResponse.StatusCode = 201;

              if not LResponse.StatusCode in [200,201] then
               raise Exception.Create( LResponse.ContentAsString );

            except
              on E:Exception do
              begin
                Result := false;
                raise Exception.Create('Error Method TCreateInstance.APIExecute'+ sLineBreak + E.Message);
              end;
            end;
          finally
            FreeAndNil(HttpClient);
            FreeAndNil(RequestBody);
          end;
     END ELSE begin
          CreateInstance;
     end;

end;

function TDTEvolutionAPI.SendText(Fone, Mensagem: string): Boolean;
var
Req   : TSendText;
begin
   try

     if ConnectionState then
     begin
         Req           := TSendText.Create;
         Result        := Req.APIExecute(FBaseURL, FKey, FInstancia, Fone, Mensagem, FVersaoAPI);
         FRespSendText := Req.RespSendText;

         FreeAndNil(Req);
     end else begin
         CreateInstance;
     end;
   finally

   end;

end;

procedure TDTEvolutionAPI.SetVersaoAPI(const Value: TVersaoAPI);
begin
  FVersaoAPI := Value;
end;

procedure TDTEvolutionAPI.Base64ToImage(const Base64String: string;Owner: TComponent);
var
  s            : TMemoryStream;
  png          : TPngImage;
  bb           : TBytes;
  TempPath     : string;
  PosDelimiter : Integer;
  DataURL      : string;
  Image        : TImage;
begin
  try
    PosDelimiter := Pos(',', Base64String);

  if PosDelimiter > 0 then
    DataURL := Copy(Base64String, PosDelimiter + 1, Length(Base64String) - PosDelimiter);
    s := TMemoryStream.Create;
    try
      bb := decodebase64(DataURL);
      if Length(bb) > 0 then
      begin
        s.WriteData(bb, Length(bb));
        s.Position := 0;
        try
          Image              := TImage.Create(Owner);
          Image.Parent       := TForm(Owner);
          Image.Left         := FqrCode.Left;
          Image.Top          := FqrCode.Top;
          Image.Width        := FqrCode.Width;
          Image.Height       := FqrCode.Height;
          Image.AutoSize     := FqrCode.AutoSize;
          Image.Proportional := FqrCode.Proportional;
          Image.Picture.LoadFromStream(s);
        finally

        end;
      end;
    finally
     // s.Free;
    end;
  except
   on E:Exception do
    begin
      raise Exception.Create('erro'+ sLineBreak + E.Message);
    end;
  end;
end;

procedure TDTEvolutionAPI.ClickEmoji(Sender: TObject);
begin
   if FEmojiComponent is TEdit then
    TEdit(FEmojiComponent).Text := TEdit(FEmojiComponent).Text + TLabel(Sender).Caption;

   if FEmojiComponent is TMemo then
    TMemo(FEmojiComponent).Lines.Text := TMemo(FEmojiComponent).Lines.Text + TLabel(Sender).Caption;
end;

function TDTEvolutionAPI.ConnectInstace: boolean;
var
Req       : TInstanceConnect;
FrmqrCode : TFrmqrCodeEvo;
begin
     Req                  := TInstanceConnect.Create;
     Result               := Req.APIExecute(FBaseURL,FKey,FInstancia);
     FRespInstanceConnect := Req.RespInstanceConnect;

     if Req.RespInstanceConnect <> nil then
     begin
       if Req.RespInstanceConnect.base64 <> '' then
       begin
          FrmqrCode           := TFrmqrCodeEvo.Create(nil);
          FqrCode             := FrmqrCode.Image1;
          FrmqrCode.BaseURL   := FBaseURL;
          FrmqrCode.Key       := FKey;
          FrmqrCode.Instancia := FInstancia;
          Base64ToImage(Req.RespInstanceConnect.base64, FrmqrCode );
          FrmqrCode.ShowModal;
       end;
     end;

     FreeAndNil(Req);
end;

function TDTEvolutionAPI.ConnectionState: Boolean;
Var
 Req : TConnectionState;
Begin

 Req    := TConnectionState.Create;
 Result := Req.APIExecute(FBaseURL,FKey,FInstancia);

 FRespConnectionState := Req.RespConnectionState;

 FreeAndNil(Req);
end;

constructor TDTEvolutionAPI.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ListaContatos    := TList<TListaContatos>.Create;
end;

function TDTEvolutionAPI.CreateInstance : boolean;
Var
 Req       : TCreateInstance;
 FrmqrCode : TFrmqrCodeEvo;
Begin
 if NOT ConnectionState then
 begin
     Req                := TCreateInstance.Create;
     Result             := Req.APIExecute(FBaseURL,FKey,FInstancia);
     FRetCreateInstance := Req.RespCreateInstance;

     if Req.RespCreateInstance <> nil then
     begin
         FrmqrCode           := TFrmqrCodeEvo.Create(nil);
         FqrCode             := FrmqrCode.Image1;
         FrmqrCode.BaseURL   := FBaseURL;
         FrmqrCode.Key       := FKey;
         FrmqrCode.Instancia := FInstancia;
         Base64ToImage(Req.RespCreateInstance.qrcode.base64, FrmqrCode );
         FrmqrCode.ShowModal;
         FreeAndNil(Req);
     end else begin
         FreeAndNil(Req);
         ConnectInstace;
     end;
 end;
end;

function TDTEvolutionAPI.DeleteInstance: Boolean;
var
  HttpClient   : THttpClient;
  LResponse    : IHttpResponse;
  RequestBody  : TStringStream;
  xURL_EXECUTE : string;
  json         : String;
begin

          xURL_EXECUTE           := BaseURL + '/instance/delete/' + FInstancia;
          HttpClient             := THTTPClient.Create;
          HttpClient.ContentType := 'application/json';
          try

            try
              {Add Body}
              RequestBody := TStringStream.Create('');
              LResponse   := HttpClient.Delete( xURL_EXECUTE,
                                             nil,
                TNetHeaders.Create(
                TNameValuePair.Create('apikey', FKey)));

              Result := LResponse.StatusCode = 200;

              if not LResponse.StatusCode in [200,201] then
               raise Exception.Create( LResponse.ContentAsString );

            except
              on E:Exception do
              begin
                Result := false;
                raise Exception.Create('Error Method TCreateInstance.APIExecute'+ sLineBreak + E.Message);
              end;
            end;
          finally
            FreeAndNil(HttpClient);
            FreeAndNil(RequestBody);
          end;

end;

destructor TDTEvolutionAPI.Destroy;
begin
  ListaContatos.Clear;

  FreeAndNil(ListaContatos);

  inherited Destroy;
end;

function TDTEvolutionAPI.fetchInstances : boolean;
var
Req : TFetchInstances;
begin
      Req    := TFetchInstances.Create;
      Result := Req.APIExec(FBaseURL, FKey, FInstancia);

      FreeAndNil(Req);
end;

function TDTEvolutionAPI.GetMimeType(const FileName: string): string;
var
  Extension: string;
begin
  Extension := ExtractFileExt(FileName).ToLower;

  if Extension = '.txt' then
    Result := 'text/plain'
  else if Extension = '.html' then
    Result := 'text/html'
  else if Extension = '.htm' then
    Result := 'text/html'
  else if Extension = '.css' then
    Result := 'text/css'
  else if Extension = '.csv' then
    Result := 'text/csv'
  else if Extension = '.xml' then
    Result := 'application/xml'
  else if Extension = '.json' then
    Result := 'application/json'
  else if Extension = '.pdf' then
    Result := 'application/pdf'
  else if Extension = '.zip' then
    Result := 'application/zip'
  else if Extension = '.gzip' then
    Result := 'application/gzip'
  else if Extension = '.tar' then
    Result := 'application/x-tar'
  else if Extension = '.rar' then
    Result := 'application/x-rar-compressed'
  else if Extension = '.7z' then
    Result := 'application/x-7z-compressed'
  else if Extension = '.jpg' then
    Result := 'image/jpeg'
  else if Extension = '.jpeg' then
    Result := 'image/jpeg'
  else if Extension = '.png' then
    Result := 'image/png'
  else if Extension = '.gif' then
    Result := 'image/gif'
  else if Extension = '.bmp' then
    Result := 'image/bmp'
  else if Extension = '.tiff' then
    Result := 'image/tiff'
  else if Extension = '.tif' then
    Result := 'image/tiff'
  else if Extension = '.ico' then
    Result := 'image/x-icon'
  else if Extension = '.svg' then
    Result := 'image/svg+xml'
  else if Extension = '.webp' then
    Result := 'image/webp'
  else if Extension = '.mp4' then
    Result := 'video/mp4'
  else if Extension = '.avi' then
    Result := 'video/x-msvideo'
  else if Extension = '.mov' then
    Result := 'video/quicktime'
  else if Extension = '.wmv' then
    Result := 'video/x-ms-wmv'
  else if Extension = '.mkv' then
    Result := 'video/x-matroska'
  else if Extension = '.mp3' then
    Result := 'audio/mpeg'
  else if Extension = '.wav' then
    Result := 'audio/wav'
  else if Extension = '.ogg' then
    Result := 'audio/ogg'
  else if Extension = '.flac' then
    Result := 'audio/flac'
  else if Extension = '.mid' then
    Result := 'audio/midi'
  else if Extension = '.midi' then
    Result := 'audio/midi'
  else if Extension = '.rtf' then
    Result := 'application/rtf'
  else if Extension = '.doc' then
    Result := 'application/msword'
  else if Extension = '.docx' then
    Result := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  else if Extension = '.ppt' then
    Result := 'application/vnd.ms-powerpoint'
  else if Extension = '.pptx' then
    Result := 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
  else if Extension = '.xls' then
    Result := 'application/vnd.ms-excel'
  else if Extension = '.xlsx' then
    Result := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  else if Extension = '.psd' then
    Result := 'image/vnd.adobe.photoshop'
  else if Extension = '.ai' then
    Result := 'application/postscript'
  else if Extension = '.eot' then
    Result := 'application/vnd.ms-fontobject'
  else if Extension = '.woff' then
    Result := 'font/woff'
  else if Extension = '.woff2' then
    Result := 'font/woff2'
  else if Extension = '.ttf' then
    Result := 'font/ttf'
  else if Extension = '.otf' then
    Result := 'font/otf'
  else if Extension = '.jar' then
    Result := 'application/java-archive'
  else if Extension = '.apk' then
    Result := 'application/vnd.android.package-archive'
  else if Extension = '.bat' then
    Result := 'application/x-bat'
  else if Extension = '.sh' then
    Result := 'application/x-sh'
  else if Extension = '.pl' then
    Result := 'application/x-perl'
  else if Extension = '.py' then
    Result := 'text/x-python'
  else if Extension = '.rb' then
    Result := 'text/x-ruby'
  else if Extension = '.cpp' then
    Result := 'text/x-c++'
  else if Extension = '.h' then
    Result := 'text/x-c'
  else
    Result := 'application/octet-stream'; // Default MIME type for unknown file types
end;


end.

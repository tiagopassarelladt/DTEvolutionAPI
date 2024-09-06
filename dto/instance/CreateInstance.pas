unit CreateInstance;

interface
  uses 
    RespCreateInstance,
    System.SysUtils,
    Generics.Collections,
    REST.Json.Types,
    Rest.Json,
    UntToken;

type

  TCreateInstance = class
  private
    FInstanceName: string;
    FQrcode      : Boolean;
    FToken       : string;
    // Instance of TRespCreateInstance
    [JSONMarshalledAttribute(False)]
    FRespCreateInstance: TRespCreateInstance;
    // Store Last Response Message from StatusCode
    [JSONMarshalledAttribute(False)]
    FResponseMessage: string;
  public
    property instanceName : string             read FInstanceName write FInstanceName;
    property qrcode       : Boolean            read FQrcode       write FQrcode;
    property token        : string             read FToken        write FToken;
    // Instance of TRespCreateInstance
    property RespCreateInstance: TRespCreateInstance read FRespCreateInstance write FRespCreateInstance;
    // Get Last Response Message from StatusCode
    property ResponseMessage: string             read FResponseMessage write FResponseMessage;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TCreateInstance;
    function APIExecute(BaseURL : string; Key : string; instancia : String): boolean;

  end;

implementation
  uses 
    System.Classes,
    System.NetEncoding,
    System.NetConsts,
    System.Net.URLClient,
    System.Net.HttpClient,
    System.Net.HttpClientComponent, fetchInstances;

{TCreateInstance}
function TCreateInstance.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

class function TCreateInstance.FromJsonString(const AJsonString: string): TCreateInstance;
begin
  Result := TJson.JsonToObject<TCreateInstance>(AJsonString);
end;

function TCreateInstance.APIExecute(BaseURL : string; Key : string; instancia : String): boolean;
var
  HttpClient   : THttpClient;
  LResponse    : IHttpResponse;
  RequestBody  : TStringStream;
  xURL_EXECUTE : string;
  json         : String;
  tk           : TToken;
  xInst        : TFetchInstances;
  xExiste      : boolean;
begin
    // VERIFICA SE A INSTANCIA EXISTE
    Result           := False;
    xExiste          := False;
    xInst            := TFetchInstances.Create;
    xExiste          := xInst.APIExec(BaseURL,Key,instancia);
    if Assigned(xInst) then
    FreeAndNil(xInst);

    if not xExiste then
    begin
          tk                     := TToken.Create;
          xURL_EXECUTE           := BaseURL + '/instance/create';
          FResponseMessage       := '';
          HttpClient             := THTTPClient.Create;
          HttpClient.ContentType := 'application/json';
          json                   :=
                                  ' { ' +
                                  ' "instanceName": "'+Instancia+'", '    +
                                  ' "token": "'+ tk.GenerateToken +'", '   +
                                  ' "qrcode": true ' +
                                  ' }';
          try
            try
              {Add Body}
              RequestBody := TStringStream.Create(json);
              LResponse   := HttpClient.Post( xURL_EXECUTE,
                                             RequestBody,nil,

                TNetHeaders.Create(
                TNameValuePair.Create('apikey', Key)));

              //FRespCreateInstance := TRespCreateInstance.FromJsonString(LResponse.ContentAsString);

              Result := LResponse.StatusCode = 200;

              if not LResponse.StatusCode in [200,201] then
               raise Exception.Create( LResponse.ContentAsString );

              Result := True;
            except
              on E:Exception do
              begin
                Result := False;
                FResponseMessage := E.Message;
                raise Exception.Create('Error Method TCreateInstance.APIExecute'+ sLineBreak + E.Message);
              end;
            end;


          finally
            FreeAndNil(HttpClient);
            FreeAndNil(RequestBody);
            if Assigned(tk) then
            FreeAndNil(tk);
          end;
    end;
end;

end.

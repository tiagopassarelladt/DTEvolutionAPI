unit ConnectionState;

interface
  uses 
    RespConnectionState,
    System.SysUtils,
    Generics.Collections,
    REST.Json.Types,
    Rest.Json;

type

  TConnectionState = class
  private
    FInstanceName: string;
    FQrcode      : Boolean;
    FToken       : string;
    // Instance of TRespConnectionState
    [JSONMarshalledAttribute(False)]
    FRespConnectionState: TRespConnectionState;
    // Store Last Response Message from StatusCode
    [JSONMarshalledAttribute(False)]
    FResponseMessage: string;
  public
    property instanceName : string              read FInstanceName write FInstanceName;
    property qrcode       : Boolean             read FQrcode       write FQrcode;
    property token        : string              read FToken        write FToken;
    // Instance of TRespConnectionState
    property RespConnectionState: TRespConnectionState read FRespConnectionState write FRespConnectionState;
    // Get Last Response Message from StatusCode
    property ResponseMessage: string              read FResponseMessage write FResponseMessage;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TConnectionState;
    function APIExecute(BaseURL : string; Key: string; Instancia : string): boolean;

  end;

implementation
  uses 
    System.Classes,
    System.NetEncoding,
    System.NetConsts,
    System.Net.URLClient,
    System.Net.HttpClient,
    System.Net.HttpClientComponent;

{TConnectionState}
function TConnectionState.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TConnectionState.FromJsonString(const AJsonString: string): TConnectionState;
begin
  Result := TJson.JsonToObject<TConnectionState>(AJsonString);
end;

function TConnectionState.APIExecute(BaseURL : string; Key: string; Instancia : string): boolean;
var
  HttpClient   : THttpClient;
  LResponse    : IHttpResponse;
  RequestBody  : TStringStream;
  xURL_EXECUTE : string;
begin
    xURL_EXECUTE     := BaseURL + '/instance/connectionstate/' + Instancia;
    FResponseMessage := '';
    HttpClient       := THTTPClient.Create;
    try
        try
          {Add Body}
          RequestBody := TStringStream.Create('');

          LResponse   := HttpClient.Get( xURL_EXECUTE,
                                         RequestBody,

            TNetHeaders.Create(
          {Add Headers}
            TNameValuePair.Create('apikey', Key)
                                       ));

          {Execute method GET and return instance of TRespConnectionState}
          FRespConnectionState := TRespConnectionState.FromJsonString(LResponse.ContentAsString);

          Result := LResponse.StatusCode = 200;

          if FRespConnectionState.instance.state <> 'open' then
          Result := False;

          if not LResponse.StatusCode in [200,201] then
           raise Exception.Create( LResponse.ContentAsString );
        except
          on E:Exception do
          begin
            Result := False;
            FResponseMessage := E.Message;
            raise Exception.Create('Error Method TConnectionState.APIExecute'+ sLineBreak + E.Message);
          end;
        end;
    finally
        FreeAndNil(HttpClient);
        FreeAndNil(RequestBody);
    end;
end;

end.


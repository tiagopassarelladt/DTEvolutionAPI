unit InstanceConnect;

interface
  uses 
    RespInstanceConnect,
    System.SysUtils,
    Generics.Collections,
    REST.Json.Types,
    Rest.Json;

type

  TInstanceConnect = class
  private
    FInstanceName: string;
    FQrcode      : Boolean;
    FToken       : string;
    // Instance of TRespInstanceConnect
    [JSONMarshalledAttribute(False)]
    FRespInstanceConnect: TRespInstanceConnect;
    // Store Last Response Message from StatusCode
    [JSONMarshalledAttribute(False)]
    FResponseMessage: string;
  public
    property instanceName : string              read FInstanceName write FInstanceName;
    property qrcode       : Boolean             read FQrcode       write FQrcode;
    property token        : string              read FToken        write FToken;
    // Instance of TRespInstanceConnect
    property RespInstanceConnect: TRespInstanceConnect read FRespInstanceConnect write FRespInstanceConnect;
    // Get Last Response Message from StatusCode
    property ResponseMessage: string              read FResponseMessage write FResponseMessage;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TInstanceConnect;
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

{TInstanceConnect}
function TInstanceConnect.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TInstanceConnect.FromJsonString(const AJsonString: string): TInstanceConnect;
begin
  Result := TJson.JsonToObject<TInstanceConnect>(AJsonString);
end;

function TInstanceConnect.APIExecute(BaseURL : string; Key: string; Instancia : string): boolean;
var
  HttpClient  : THttpClient;
  LResponse   : IHttpResponse;
  RequestBody : TStringStream;
  xURL_EXECUTE : string;
begin
    xURL_EXECUTE     := BaseURL + '/instance/connect/' + Instancia;
    FResponseMessage := '';
    HttpClient       := THTTPClient.Create;
    try
        try
          {Add Body}
          RequestBody := TStringStream.Create('');

          LResponse   := HttpClient.Get( xURL_EXECUTE,
                                         RequestBody,

            TNetHeaders.Create(
            TNameValuePair.Create('apikey', key)
                                       ));
          FRespInstanceConnect := TRespInstanceConnect.FromJsonString(LResponse.ContentAsString);

          Result := LResponse.StatusCode = 200;


          if not LResponse.StatusCode in [200,201] then
           raise Exception.Create( LResponse.ContentAsString );
        except
          on E:Exception do
          begin
            Result := False;
            FResponseMessage := E.Message;
            raise Exception.Create('Error Method TInstanceConnect.APIExecute'+ sLineBreak + E.Message);
          end;
        end;
    finally
       FreeAndNil(HttpClient);
       FreeAndNil(RequestBody);
    end;
end;

end.
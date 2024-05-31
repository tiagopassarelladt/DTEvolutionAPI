unit fetchInstances;

interface
  uses 
    RespfetchInstances,
    System.SysUtils,
    Generics.Collections,
    REST.Json.Types,
    Rest.Json;

type

  TFetchInstances = class
  private
    FInstanceName: string;
    FQrcode      : Boolean;
    FToken       : string;

  public
    property instanceName : string             read FInstanceName write FInstanceName;
    property qrcode       : Boolean            read FQrcode       write FQrcode;
    property token        : string             read FToken        write FToken;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TFetchInstances;
    function APIExec(BaseURL : string; Key : string; instancia : String): boolean;
  end;

implementation
  uses 
    System.Classes,
    System.NetEncoding,
    System.NetConsts,
    System.Net.URLClient,
    System.Net.HttpClient,
    System.Net.HttpClientComponent;

{TFetchInstances}
function TFetchInstances.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TFetchInstances.FromJsonString(const AJsonString: string): TFetchInstances;
begin
  Result := TJson.JsonToObject<TFetchInstances>(AJsonString);
end;

function TFetchInstances.APIExec(BaseURL : string; Key : string; instancia : String): boolean;
var
  HttpClient   : THttpClient;
  LResponse    : IHttpResponse;
  RequestBody  : TStringStream;
  xURL_EXECUTE : string;
  json         : String;
begin
    xURL_EXECUTE     := BaseURL + '/instance/fetchInstances';
    HttpClient       := THTTPClient.Create;
    HttpClient.ContentType := 'application/json';
    try

        try
          {Add Body}
          RequestBody := TStringStream.Create('');

          LResponse   := HttpClient.Get( xURL_EXECUTE,
                                         RequestBody,

            TNetHeaders.Create(
          {Add Headers}
            TNameValuePair.Create('apikey', Key),
            TNameValuePair.Create('instanceName', instancia)));


          Result := LResponse.StatusCode = 200;

          if Length(LResponse.ContentAsString) <= 3 then
          Result := False;


          if not LResponse.StatusCode in [200,201] then
           raise Exception.Create( LResponse.ContentAsString );
        except
          on E:Exception do
          begin
            Result := False;
            raise Exception.Create('Error Method TCreateInstance.APIExecute'+ sLineBreak + E.Message);
          end;
        end;
    finally
       FreeAndNil(HttpClient);
       FreeAndNil(RequestBody);
    end;
end;

end.

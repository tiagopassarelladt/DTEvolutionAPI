unit RespInstanceConnect;

interface
  uses 
    System.SysUtils,
    Generics.Collections,
    REST.Json.Types,
    Rest.Json;

type

  TRespInstanceConnect = class
  private
    FBase64: string;
    FCode  : string;
    FCount : Extended;
  public
    property base64 : string   read FBase64 write FBase64;
    property code   : string   read FCode   write FCode;
    property count  : Extended read FCount  write FCount;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TRespInstanceConnect;
  end;

implementation

{TRespInstanceConnect}
function TRespInstanceConnect.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TRespInstanceConnect.FromJsonString(const AJsonString: string): TRespInstanceConnect;
begin
  Result := TJson.JsonToObject<TRespInstanceConnect>(AJsonString);
end;

end.

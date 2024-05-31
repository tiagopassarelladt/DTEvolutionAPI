unit RespConnectionState;

interface
  uses 
    System.SysUtils,
    Generics.Collections,
    REST.Json.Types,
    Rest.Json;

type

  TInstance = class
  private
    FInstanceName: string;
    FState       : string;
  public
    property instanceName : string read FInstanceName write FInstanceName;
    property state        : string read FState        write FState;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TInstance;
  end;

  TRespConnectionState = class
  private
    FInstance: TInstance;
  public
    constructor Create;
    destructor Destroy; override;

    property instance : TInstance read FInstance write FInstance;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TRespConnectionState;
  end;

implementation

{TInstance}
function TInstance.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TInstance.FromJsonString(const AJsonString: string): TInstance;
begin
  Result := TJson.JsonToObject<TInstance>(AJsonString);
end;

{TRespConnectionState}
constructor TRespConnectionState.Create;
begin
  inherited;

  FInstance := TInstance.Create;
end;

destructor TRespConnectionState.Destroy;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);

  inherited;
end;

function TRespConnectionState.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TRespConnectionState.FromJsonString(const AJsonString: string): TRespConnectionState;
begin
  Result := TJson.JsonToObject<TRespConnectionState>(AJsonString);
end;

end.



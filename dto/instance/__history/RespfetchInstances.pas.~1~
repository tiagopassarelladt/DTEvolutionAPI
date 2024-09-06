unit RespfetchInstances;

interface
  uses 
    System.SysUtils,
    Generics.Collections,
    REST.Json.Types,
    Rest.Json;

type

  TIntegration = class
  private
    FToken              : string;
    FWebhook_wa_business: string;
  public
    property token               : string read FToken               write FToken;
    property webhook_wa_business : string read FWebhook_wa_business write FWebhook_wa_business;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TIntegration;
  end;

  TInstance = class
  private
    FApikey      : string;
    FInstanceId  : string;
    FInstanceName: string;
    FIntegration : TIntegration;
    FServerUrl   : string;
    FStatus      : string;
  public
    constructor Create;
    destructor Destroy; override;

    property apikey       : string       read FApikey       write FApikey;
    property instanceId   : string       read FInstanceId   write FInstanceId;
    property instanceName : string       read FInstanceName write FInstanceName;
    property integration  : TIntegration read FIntegration  write FIntegration;
    property serverUrl    : string       read FServerUrl    write FServerUrl;
    property status       : string       read FStatus       write FStatus;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TInstance;
  end;

  TRespfetchInstances = class
  private
    FInstance: TInstance;
  public
    constructor Create;
    destructor Destroy; override;

    property instance : TInstance read FInstance write FInstance;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TRespfetchInstances;
  end;

implementation

{TIntegration}
function TIntegration.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TIntegration.FromJsonString(const AJsonString: string): TIntegration;
begin
  Result := TJson.JsonToObject<TIntegration>(AJsonString);
end;

{TInstance}
constructor TInstance.Create;
begin
  inherited;

  FIntegration := TIntegration.Create;
end;

destructor TInstance.Destroy;
begin
  if Assigned(FIntegration) then
    FreeAndNil(FIntegration);

  inherited;
end;

function TInstance.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TInstance.FromJsonString(const AJsonString: string): TInstance;
begin
  Result := TJson.JsonToObject<TInstance>(AJsonString);
end;

{TRespfetchInstances}
constructor TRespfetchInstances.Create;
begin
  inherited;

  FInstance := TInstance.Create;
end;

destructor TRespfetchInstances.Destroy;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);

  inherited;
end;

function TRespfetchInstances.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TRespfetchInstances.FromJsonString(const AJsonString: string): TRespfetchInstances;
begin
  Result := TJson.JsonToObject<TRespfetchInstances>(AJsonString);
end;

end.

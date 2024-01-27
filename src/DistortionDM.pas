unit DistortionDM;

interface

uses 
  Windows, Messages, SysUtils, Classes, Forms, 
  DAVDCommon, DVSTModule;

type
  TDistortionDataModule = class(TVSTModule)
    procedure VSTModuleEditOpen(Sender: TObject; var GUI: TForm; ParentWindow: Cardinal);
    procedure DistortionDataModuleParameterProperties1ParameterChange(
      Sender: TObject; const Index: Integer; var Value: Single);
    procedure VSTModuleCreate(Sender: TObject);
    procedure VSTModuleProcess(const Inputs,
      Outputs: TAVDArrayOfSingleDynArray; const SampleFrames: Integer);
    procedure DistortionDataModuleParameterProperties0ParameterChange(
      Sender: TObject; const Index: Integer; var Value: Single);
  private
    FVolume: Single;
    FLevel: Single;
    function ClipSignal(Value, Threshold: Single): Single;
  public
  end;

implementation

{$R *.DFM}

uses
  DistortionFrm;

procedure TDistortionDataModule.VSTModuleEditOpen(Sender: TObject; var GUI: TForm; ParentWindow: Cardinal);
begin
  // Membuka GUI pengaturan distorsi saat di-edit
  GUI := TEditorDistortion.Create(Self);
end;

procedure TDistortionDataModule.DistortionDataModuleParameterProperties1ParameterChange(
  Sender: TObject; const Index: Integer; var Value: Single);
begin
  // Mengatur nilai volume sesuai dengan parameter yang diberikan
  // Anda mungkin ingin menambahkan batasan nilai volume sesuai kebutuhan aplikasi
  // Misalnya, memastikan nilai volume berada dalam kisaran yang diterima.
  FVolume := Value;
end;

procedure TDistortionDataModule.VSTModuleCreate(Sender: TObject);
begin
  // Inisialisasi nilai volume ke maksimum (1.0) dan level distorsi default (0.2)
  FVolume := 1.0;
  FLevel := 0.2;
end;

procedure TDistortionDataModule.VSTModuleProcess(const Inputs,
  Outputs: TAVDArrayOfSingleDynArray; const SampleFrames: Integer);
var
  j: Integer;
  clipThreshold: Single;
begin
  // Setel ambang kliping berdasarkan parameter level distorsi
  clipThreshold := FLevel * 441; // Contoh: Kalikan dengan faktor tertentu

  for j := 0 to SampleFrames - 1 do
  begin
    // Terapkan kliping secara langsung
    Outputs[0, j] := ClipSignal(Inputs[0, j] * FVolume, clipThreshold);
    Outputs[1, j] := ClipSignal(Inputs[1, j] * FVolume, clipThreshold);

    // Log input dan output untuk keperluan debugging
    // Uncomment baris-baris berikut untuk tujuan debugging
    // OutputDebugString(PChar(Format('Input: %f, Output: %f', [Inputs[0, j], Outputs[0, j]])));
  end;
end;

procedure TDistortionDataModule.DistortionDataModuleParameterProperties0ParameterChange(
  Sender: TObject; const Index: Integer; var Value: Single);
begin
  // Setel level distorsi berdasarkan nilai parameter
  FLevel := Value;
end;

function TDistortionDataModule.ClipSignal(Value, Threshold: Single): Single;
begin
  // Terapkan kliping dengan membatasi amplitudo hingga ambang batas
  if Value > Threshold then
    Result := Threshold
  else if Value < -Threshold then
    Result := -Threshold
  else
    Result := Value;
end;

end.


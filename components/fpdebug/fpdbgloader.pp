{ $Id$ }
{
 ---------------------------------------------------------------------------
 fpdbgloader.pp  -  Native Freepascal debugger - Section loader
 ---------------------------------------------------------------------------

 This unit contains helper classes for loading secions form images.

 This file contains some functionality ported from DUBY. See svn log for details

 ---------------------------------------------------------------------------

 @created(Mon Aug 1st WET 2006)
 @lastmod($Date$)
 @author(Marc Weustink <marc@@dommelstein.nl>)

 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.   *
 *                                                                         *
 ***************************************************************************
}
unit FpDbgLoader;

{$mode objfpc}{$H+}
{$IFDEF INLINE_OFF}{$INLINE OFF}{$ENDIF}

interface

uses
  LCLType,
  FpImgReaderBase,
  fpDbgSymTable, DbgIntfBaseTypes,
  Classes, SysUtils, contnrs, FpDbgCommon;

type

  {$ifdef windows}
    {$define USE_WIN_FILE_MAPPING}
  {$endif}

  TDbgImageLoaderList = class;

  { TDbgImageLoader }

  TDbgImageLoader = class(TObject)
  private
    FFileLoader: TDbgFileLoader;
    FFileName: String;
    FImgReader: TDbgImageReader;
    function GetAddressMapList: TDbgAddressMapList;
    function GetImageBase: QWord;
    function GetRelocationOffset: QWord;
    function GetReaderErrors: String;
    function GetSubFiles: TStrings;
    function GetTargetInfo: TTargetDescriptor;
    function GetUUID: TGuid;
  protected
    function GetSection(const AName: String): PDbgImageSection; virtual;
    function GetSection(const ID: integer): PDbgImageSection; virtual;
    property ImgReader: TDbgImageReader read FImgReader write FImgReader;
  public
    constructor Create; virtual;
    constructor Create(AFileName: String; ADebugMap: TObject = nil;
      ALoadedTargetImageAddr: TDBGPtr = 0);
    constructor Create(AnImageReader: TDbgImageReader);
    {$ifdef USE_WIN_FILE_MAPPING}
    constructor Create(AFileHandle: THandle; ADebugMap: TObject = nil;
      ALoadedTargetImageAddr: TDBGPtr = 0);
    {$endif}
    destructor Destroy; override;
    procedure ParseSymbolTable(AFpSymbolInfo: TfpSymbolList); virtual;
    procedure CloseFileLoader;
    procedure AddToLoaderList(ALoaderList: TDbgImageLoaderList);
    function IsValid: Boolean;
    function EnclosesAddressRange(AStartAddress, AnEndAddress: TDBGPtr): Boolean;

    property FileName: String read FFileName; // Empty if using USE_WIN_FILE_MAPPING
    property ImageBase: QWord read GetImageBase;
    property RelocationOffset: QWord read GetRelocationOffset;
    property TargetInfo: TTargetDescriptor read GetTargetInfo;

    property UUID: TGuid read GetUUID;
    property Section[const AName: String]: PDbgImageSection read GetSection;
    property SectionByID[const ID: integer]: PDbgImageSection read GetSection;
    // On Darwin, the Dwarf-debuginfo is not linked into the main
    // executable, but has to be read from the object files.
    property SubFiles: TStrings read GetSubFiles;
    // This is to map the addresses inside the object file
    // to their corresponding addresses in the executable. (Darwin)
    property AddressMapList: TDbgAddressMapList read GetAddressMapList;
    property ReaderErrors: String read GetReaderErrors;
  end;

  { TDbgImageLoaderLibrary }

  TDbgImageLoaderLibrary = class(TDbgImageLoader)
  public
    procedure ParseSymbolTable(AFpSymbolInfo: TfpSymbolList); override;
  end;

  { TDbgImageLoaderList }

  TDbgImageLoaderList = class(TFPObjectList)
  private
    function GetRelocationOffset: QWord;
    function GetImageBase: QWord;
    function GetTargetInfo: TTargetDescriptor;
    function GetItem(Index: Integer): TDbgImageLoader;
    procedure SetItem(Index: Integer; AValue: TDbgImageLoader);
  public
    function EnclosesAddressRange(AStartAddress, AnEndAddress: TDBGPtr): Boolean;

    property Items[Index: Integer]: TDbgImageLoader read GetItem write SetItem; default;
    property ImageBase: QWord read GetImageBase;
    property RelocationOffset: QWord read GetRelocationOffset;
    property TargetInfo: TTargetDescriptor read GetTargetInfo;
  end;

implementation

{ TDbgImageLoaderList }

function TDbgImageLoaderList.GetRelocationOffset: QWord;
begin
  if Count>0 then
    result := Items[0].RelocationOffset
  else
    Result := 0;
end;

function TDbgImageLoaderList.GetImageBase: QWord;
begin
  if Count>0 then
    result := Items[0].ImageBase
  else
    result := 0;
end;

function TDbgImageLoaderList.GetTargetInfo: TTargetDescriptor;
begin
  if Count>0 then
    result := Items[0].TargetInfo
  else
    Result := hostDescriptor;
end;

function TDbgImageLoaderList.GetItem(Index: Integer): TDbgImageLoader;
begin
  result := TDbgImageLoader(inherited GetItem(Index));
end;

procedure TDbgImageLoaderList.SetItem(Index: Integer; AValue: TDbgImageLoader);
begin
  inherited SetItem(Index, AValue);
end;

function TDbgImageLoaderList.EnclosesAddressRange(AStartAddress, AnEndAddress: TDBGPtr): Boolean;
var
  i: Integer;
begin
  for i := 0 to Count -1 do
    if Items[0].EnclosesAddressRange(AStartAddress, AnEndAddress) then
      Exit(True);
  Result := False;
end;

{ TDbgImageLoaderLibrary }

procedure TDbgImageLoaderLibrary.ParseSymbolTable(AFpSymbolInfo: TfpSymbolList);
begin
  inherited ParseSymbolTable(AFpSymbolInfo);
  if IsValid then
    FImgReader.ParseLibrarySymbolTable(AFpSymbolInfo);
end;

{ TDbgImageLoader }

function TDbgImageLoader.GetTargetInfo: TTargetDescriptor;
begin
  if assigned(ImgReader) then
    result := ImgReader.TargetInfo
  else
    result := hostDescriptor;
end;

function TDbgImageLoader.GetAddressMapList: TDbgAddressMapList;
begin
  if IsValid then
    result := FImgReader.AddressMapList
  else
    result := nil
end;

function TDbgImageLoader.GetImageBase: QWord;
begin
  if Assigned(FImgReader) then
    Result := FImgReader.ImageBase
  else
    Result := 0;
end;

function TDbgImageLoader.GetRelocationOffset: QWord;
begin
  if Assigned(FImgReader) then
    Result := FImgReader.RelocationOffset
  else
    Result := 0;
end;

function TDbgImageLoader.GetReaderErrors: String;
begin
  if FImgReader <> nil then
    Result := FImgReader.ReaderErrors
  else
    Result := '';
end;

function TDbgImageLoader.GetSubFiles: TStrings;
begin
  if IsValid then
    result := FImgReader.SubFiles
  else
    result := nil;
end;

function TDbgImageLoader.GetUUID: TGuid;
begin
  if assigned(FImgReader) then
    result := FImgReader.UUID
  else
    result := GUID_NULL;
end;

function TDbgImageLoader.GetSection(const AName: String): PDbgImageSection;
begin
  if FImgReader <> nil then
    Result := FImgReader.Section[AName]
  else
    Result := nil;
end;

function TDbgImageLoader.GetSection(const ID: integer): PDbgImageSection;
begin
  if FImgReader <> nil then
    Result := FImgReader.SectionByID[ID]
  else
    Result := nil;
end;

constructor TDbgImageLoader.Create;
begin
  inherited Create;
end;

constructor TDbgImageLoader.Create(AFileName: String; ADebugMap: TObject;
  ALoadedTargetImageAddr: TDBGPtr);
begin
  FFileName := AFileName;
  try
    FFileLoader := TDbgFileLoader.Create(AFileName);
  except
    // When the creation of the FileLoader fails, it is not possible to find
    // a suiteable ImageReader. So skip that step.
    // This happens on Linux when the shared memory is file-mapped to
    // a SysV IPC shm segment (SYSV00000000), or the file is deleted (or both)
    Exit;
  end;
  FImgReader := GetImageReader(FFileLoader, ADebugMap, ALoadedTargetImageAddr, False);
  if not Assigned(FImgReader) then
    FreeAndNil(FFileLoader);
end;

constructor TDbgImageLoader.Create(AnImageReader: TDbgImageReader);
begin
  inherited Create;
  FImgReader := AnImageReader;
end;

{$ifdef USE_WIN_FILE_MAPPING}
constructor TDbgImageLoader.Create(AFileHandle: THandle; ADebugMap: TObject;
  ALoadedTargetImageAddr: TDBGPtr);
begin
  FFileLoader := TDbgFileLoader.Create(AFileHandle);
  FImgReader := GetImageReader(FFileLoader, ADebugMap, ALoadedTargetImageAddr, False);
  if not Assigned(FImgReader) then
    FreeAndNil(FFileLoader);
end;
{$endif}

destructor TDbgImageLoader.Destroy;
begin
  FreeAndNil(FImgReader);
  FreeAndNil(FFileLoader);
  inherited Destroy;
end;

procedure TDbgImageLoader.ParseSymbolTable(AFpSymbolInfo: TfpSymbolList);
begin
  if IsValid then
    FImgReader.ParseSymbolTable(AFpSymbolInfo);
end;

procedure TDbgImageLoader.CloseFileLoader;
begin
  if FFileLoader <> nil then
    FFileLoader.Close;
end;

procedure TDbgImageLoader.AddToLoaderList(ALoaderList: TDbgImageLoaderList);
begin
  ALoaderList.Add(Self);
  FImgReader.AddSubFilesToLoaderList(ALoaderList, Self);
end;

function TDbgImageLoader.IsValid: Boolean;
begin
  Result := FImgReader <> nil;
end;

function TDbgImageLoader.EnclosesAddressRange(AStartAddress, AnEndAddress: TDBGPtr): Boolean;
begin
  Result := False;
  if not IsValid then
    Exit;
  Result := FImgReader.EnclosesAddressRange(AStartAddress, AnEndAddress);
end;

end.


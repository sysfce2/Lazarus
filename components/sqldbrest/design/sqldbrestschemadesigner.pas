{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit sqldbrestschemadesigner;

{$warn 5023 off : no warning about unused units}
interface

uses
  dlgrestfieldoptions, dlgsqldbrestconnection, fraconnections, fraschematableseditor, frasqldbfullrestschemaaditor, 
  frasqldbrestfieldedit, frasqldbrestresourceedit, fraSQLDBRestSchemaEditor, frmeditframedialog, sqldbschemaedittools, 
  frasqldbresourcefields, build304, frasqldbresourceparams, frasqldbrestparamedit, schemaeditorconf, dlgeditorsettings, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('sqldbrestschemadesigner', @Register);
end.

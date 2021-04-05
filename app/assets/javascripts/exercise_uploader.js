var old_file_list =  document.getElementById("exercise_oldfileList").value.split(' ')
var old_files_name = transfer_data("exercise_oldfileList")
var old_files_name_backup = old_files_name.slice()
var old_files_hash_name = transfer_data("exercise_ownerships_res_name")
var total_list = old_files_name.slice()
var table = document.getElementById("tablelist")
var path = "/uploads/resource_file/"
document.getElementById("exercise_fileList").value = total_list.toString()   

function apply_hide_and_show(){
  if(total_list.length==0){
    $(filelist).addClass("hidden");
  }
  else{
    $(function () {
      $('#filelist').removeClass('hidden')
    })
  }
}


function transfer_data(tag){
  var data = []
  old_file_list =  document.getElementById(tag).value.split(' ')
  for( var i = 0; i < old_file_list.length; i++){ 
    if(old_file_list[i].replace(/\s/g, '').length){
      data.push(old_file_list[i])
    }
  }
  return data
}


function remove_ele(arr,ele){
  if(!Array.isArray(arr)){
    arr = arr.split(",")
  }
  for( var i = 0; i < arr.length; i++){ 
    if ( arr[i] == ele.trim()) { 
        arr.splice(i, 1)
    }
  }
  return arr
}


function delete_table_row(row){
    var count = $('#tablelist tr').length;
    if(row == -1){
      for(var i = 1; i < count; i++){
        table.deleteRow(1)
      }
    }
    else{
      var entire_row= document.getElementById(row+"row")
      entire_row.remove()
    }
}



function is_image(file_name){
  var file_name = /[^.]+$/.exec(file_name)
  if (String(file_name).match(/(jpg|jpeg|png|gif)/g))
    return true
  return false
}


function add_button_listener(){
  document.getElementById("tablelist").addEventListener('click',function(e){
      if(e.target && e.target.id != null && e.target.id!= ""  && e.target.id.length<=2 ){
        var id = parseInt(e.target.id.charAt(0))
        var file_name = document.getElementById(id+"name").innerHTML.trim()  
        total_list = remove_ele(total_list, file_name)
        if(old_files_name.includes(file_name)){
          old_files_name = remove_ele(old_files_name, file_name)
        }
        delete_table_row(id)
        document.getElementById("exercise_fileList").value = total_list.toString()   
        apply_hide_and_show()
    }
 });
}


function check_res(file_name){
  var a = old_files_name_backup.indexOf(file_name)
  if(a != -1){
    return old_files_hash_name[a]
  }
  return null
}


function create_text_and_button(file_name,size_list){
  delete_table_row(-1)
  for (var i = 0; i < file_name.length; i++) {
    var exist = check_res(file_name[i])
    var row = table.insertRow();
    row.setAttribute("id",(i+1)+"row")
    var image_or_not = is_image(file_name[i])
    // Type info
    var cell0 = row.insertCell(0)
    if(image_or_not){
      cell0.innerHTML = "Image"
    }
    else{
      cell0.innerHTML = "File"
    }
    // Thumbnail display
    var cell1 = row.insertCell(1)
    if(exist != null && image_or_not){
      cell1.innerHTML = "<img class=\"img\" src=\""+path+exist+"\">"
    }
    else if (exist != null && !image_or_not){
      cell1.innerHTML = "Not showable"
    }
    else{
      cell1.innerHTML = "Unknown"
    }
    //Name text
    var cell2 = row.insertCell(2)
    cell2.setAttribute("id",(i+1)+"name")
    cell2.innerHTML = file_name[i]
    //Pixel text
    var cell3 = row.insertCell(3)
    var temp_src = path+old_files_hash_name[i]
    if(exist != null && image_or_not){
      var img = new Image()
      img.src = temp_src
      cell3.innerHTML = img.width + 'x' + img.height+" pixels" 
    }
    else if (exist != null && !image_or_not){
      //wait
    }
    else if (exist == null && image_or_not){
      cell3.innerHTML = "0x0 pixels"
    }  else if (exist == null && !image_or_not){
      var index = i - old_files_name.length
      cell3.innerHTML =  size_list[index] + " bytes"
    }
    //Mark icon
    var cell4 = row.insertCell(4)
    if(exist != null){
      cell4.innerHTML = "<a href=\"#\">  <span class=\"glyphicon glyphicon-ok iconpadding fa-lg\"></span> </a>"
    }else{
      cell4.innerHTML = "<a >  <span class=\"glyphicon glyphicon-remove iconpadding fa-lg\"></span> </a>"
    }
    //Delete Button
    var cell5 = row.insertCell(5)
    cell5.innerHTML = "<button class=\"btn btn-link glyphicon glyphicon-trash fa-lg\" id="+(i+1)+" type=\"button\"></button>"
  }
  add_button_listener()
}


// upload button
$("#exercise_files").bind("change", function (e)
{
  total_list = old_files_name.slice()
  var size_list=[]
  var file = document.getElementById("exercise_files")
  for (var i = 0; i < file.files.length; i++) {
    file_name = file.files[i].name
    if(total_list.indexOf(file_name) === -1) {
      total_list.push(file_name.trim())
      size_list.push(file.files[i].size)
    }
  } 
  document.getElementById("exercise_fileList").value = total_list.toString()  
  apply_hide_and_show()
  create_text_and_button(total_list,size_list)
});


apply_hide_and_show()
create_text_and_button(old_files_name,"old")


// **************** upload exercise description *****************************


document.getElementById("exercise_description").onchange = function() {
  // $(this).parents('form').submit();
};

// $(document).on("change", "input.fa-upload", function(e){
//   $(this).parents('form').submit();
// });

// document.getElementById('yaml')
//   .addEventListener('change', getFile)

// function FileSelected() {
//   document.getElementById('yaml')
//     .addEventListener('change', getFile)
// }

// function FileSelected() {
//   document.getElementById('yaml')
//     .addEventListener('change', getFile)
// }

// function getFile(event) {
// 	const input = event.target
//   if ('files' in input && input.files.length > 0) {
//     extention= input.files[0].name.split('.')
//     // Only support yaml and tar file.
//     if(extention[extention.length-1] == "yaml"){
//       placeFileContent(input.files[0])
//     }
//     else{
//         // FileHelper.loadFileAsBinaryString
//         // (
//         //     event.srcElement.files[0],
//         //     null,
//         //     inputTarFileToLoad_Change2 
//         // );
//         document.getElementById("exercise_description").submit();
//     }
//   }
// }

// function update_code(content) {
//   target = document.getElementById('exercise_exercise_version_text_representation'),
//   target.innerHTML = content
//   //update CodeMirror
//   $('.cm-s-aptana').remove();
//   var editor = CodeMirror.fromTextArea(document.getElementById("exercise_exercise_version_text_representation"), {
//     mode: "yaml",
//     gutters: ["code"], 
//     lineNumbers: true,
//   });
//   $('.cm-s-default').addClass("cm-s-aptana CodeMirror-wrap CodeMirror");
//   editor.setValue(content)
// }

// // **************** upload yaml file *****************************
// //update textarea
// function placeFileContent(file) {
// 	readFileContent(file).then(content => {
//     update_code(content)
//   }).catch(error => console.log(error))
// }


// function readFileContent(file) {
// 	const reader = new FileReader()
//   return new Promise((resolve, reject) => {
//     reader.onload = event => resolve(event.target.result)
//     reader.onerror = error => reject(error)
//     reader.readAsText(file)
//   })
// }



// // **************** upload tar file *****************************


// function inputTarFileToLoad_Change(event)
// {
//     var fileToLoad = event.srcElement.files[0];    
    
//     if (fileToLoad != null)
//     {
//         FileHelper.loadFileAsBinaryString
//         (
//             fileToLoad,
//             null, 
//             inputTarFileToLoad_Change2 
//         );
//     }
// }
 



// function inputTarFileToLoad_Change2(fileToLoad, fileAsBinaryString)
// {

//     var fileName = fileToLoad.name;
//     var fileAsBytes = ByteHelper.stringUTF8ToBytes(fileAsBinaryString);
//     var tarFile = TarFile.fromBytes(fileName, fileAsBytes);
     
//     Globals.Instance.tarFile = tarFile;
     
//     var tarFile = Globals.Instance.tarFile;
//     DOMDisplayHelper.tarFileToDOMElement(tarFile);
// }
 
 

 
// function ByteHelper()
// {}
// {
//     ByteHelper.BitsPerByte = 8;
//     ByteHelper.BitsPerNibble = ByteHelper.BitsPerByte / 2;
//     ByteHelper.ByteValueMax = Math.pow(2, ByteHelper.BitsPerByte) - 1;
 
 
//     ByteHelper.stringUTF8ToBytes = function(stringToConvert)
//     {
//         var returnValues = [];
 
//         for (var i = 0; i < stringToConvert.length; i++)
//         {
//             var charCode = stringToConvert.charCodeAt(i);
//             returnValues.push(charCode);
//         }
 
//         return returnValues;
//     }

// }
 
// function ByteStream(bytes)
// {
//     this.bytes = bytes;  
 
//     this.byteIndexCurrent = 0;
// }
// {
//     // constants
 
//     ByteStream.BitsPerByte = 8;
//     ByteStream.BitsPerByteTimesTwo = ByteStream.BitsPerByte * 2;
//     ByteStream.BitsPerByteTimesThree = ByteStream.BitsPerByte * 3;
 
//     // instance methods
 
//     ByteStream.prototype.hasMoreBytes = function()
//     {
//         return (this.byteIndexCurrent < this.bytes.length);
//     }
     
//     ByteStream.prototype.readBytes = function(numberOfBytesToRead)
//     {
//         var returnValue = [];
 
//         for (var b = 0; b < numberOfBytesToRead; b++)
//         {
//             returnValue[b] = this.readByte();
//         }
 
//         return returnValue;
//     }
 
//     ByteStream.prototype.readByte = function()
//     {
//         var returnValue = this.bytes[this.byteIndexCurrent];
 
//         this.byteIndexCurrent++;
 
//         return returnValue;
//     }
 
//     ByteStream.prototype.readString = function(lengthOfString)
//     {
//         var returnValue = "";
 
//         for (var i = 0; i < lengthOfString; i++)
//         {
//             var byte = this.readByte();
 
//             if (byte != 0)
//             {
//                 var byteAsChar = String.fromCharCode(byte);
//                 returnValue += byteAsChar;
//             }
//         }
 
//         return returnValue;
//     }
 
//     ByteStream.prototype.writeBytes = function(bytesToWrite)
//     {
//         for (var b = 0; b < bytesToWrite.length; b++)
//         {
//             this.bytes.push(bytesToWrite[b]);
//         }
 
//         this.byteIndexCurrent = this.bytes.length;
//     }
 
//     ByteStream.prototype.writeByte = function(byteToWrite)
//     {
//         this.bytes.push(byteToWrite);
 
//         this.byteIndexCurrent++;
//     }
 
//     ByteStream.prototype.writeString = function(stringToWrite, lengthPadded)
//     {   
//         for (var i = 0; i < stringToWrite.length; i++)
//         {
//             this.writeByte(stringToWrite.charCodeAt(i));
//         }
         
//         var numberOfPaddingChars = lengthPadded - stringToWrite.length;
//         for (var i = 0; i < numberOfPaddingChars; i++)
//         {
//             this.writeByte(0);
//         }
//     }
// }
 
// function DOMDisplayHelper()
// {
// }
// {
//     DOMDisplayHelper.tarFileToDOMElement = function(tarFile)
//     {
 
//         for (var i = 0; i < tarFile.entries.length; i++)
//         {
//             var entry = tarFile.entries[i];
//             filename = entry.header.fileName
//             extention = filename.split(".").pop()
//             if (extention == "yaml"){
//                  entry.download(entry);
//             }
           
//         }
 
//         return null;
//     }  
// }
 
// function FileHelper()
// {
// }
// {
//     FileHelper.loadFileAsBinaryString = function(fileToLoad, contextForCallback, callback)
//     {   
//         var fileReader = new FileReader();
//         fileReader.onloadend = function(fileLoadedEvent)
//         {
//           console.log(fileLoadedEvent)
//             var returnValue = null;
 
//             if (fileLoadedEvent.target.readyState == FileReader.DONE)
//             {
//                 returnValue = fileLoadedEvent.target.result;
//             }
           
//             callback.call
//             (
//                 contextForCallback, 
//                 fileToLoad,
//                 returnValue
//             );
//         }
   
//         fileReader.readAsBinaryString(fileToLoad);
//     }
 
//     FileHelper.saveBytesAsFile = function(bytesToWrite, fileNameToSaveAs)
//     {
//         var bytesToWriteAsArrayBuffer = new ArrayBuffer(bytesToWrite.length);
//         var bytesToWriteAsUIntArray = new Uint8Array(bytesToWriteAsArrayBuffer);
//         for (var i = 0; i < bytesToWrite.length; i++) 
//         {
//             bytesToWriteAsUIntArray[i] = bytesToWrite[i];
//         }
 
//         var bytesToWriteAsBlob = new Blob
//         (
//             [ bytesToWriteAsArrayBuffer ], 
//             { type:"application/type" }
//         );
//         const reader = new FileReader();
//         reader.addEventListener('loadend', (e) => {
//           const text = e.srcElement.result;
//           update_code(text)
//         });
//         reader.readAsText(bytesToWriteAsBlob);
//     }
// }
 
// function Globals()
// {
// }
// {
//     Globals.Instance = new Globals();
// }
 

 
// function TarFile(fileName, entries)
// {
//     this.fileName = fileName;
//     this.entries = entries;
// }
// {

//     TarFile.ChunkSize = 512;
 
//     TarFile.fromBytes = function(fileName, bytes)
//     {
//         var reader = new ByteStream(bytes);
 
//         var entries = [];
 
//         var chunkSize = TarFile.ChunkSize;
 
//         var numberOfConsecutiveZeroChunks = 0;
 
//         while (reader.hasMoreBytes() == true)
//         {
//             var chunkAsBytes = reader.readBytes(chunkSize);
 
//             var areAllBytesInChunkZeroes = true;
 
//             for (var b = 0; b < chunkAsBytes.length; b++)
//             {
//                 if (chunkAsBytes[b] != 0)
//                 {
//                     areAllBytesInChunkZeroes = false;
//                     break;
//                 }
//             }
 
//             if (areAllBytesInChunkZeroes == true)
//             {
//                 numberOfConsecutiveZeroChunks++;
 
//                 if (numberOfConsecutiveZeroChunks == 2)
//                 {
//                     break;
//                 }
//             }
//             else
//             {
//                 numberOfConsecutiveZeroChunks = 0;
 
//                 var entry = TarFileEntry.fromBytes(chunkAsBytes, reader);
 
//                 entries.push(entry);
//             }
//         }
 
//         var returnValue = new TarFile
//         (
//             fileName,
//             entries
//         );
 
//         return returnValue;
//     }
     
//     TarFile.new = function(fileName)
//     {
//         return new TarFile
//         (
//             fileName,
//             [] // entries
//         );
//     }


     
//     TarFile.prototype.toBytes = function()
//     {
//         var fileAsBytes = [];       
//         var entriesAsByteArrays = [];
         
//         for (var i = 0; i < this.entries.length; i++)
//         {
//             var entry = this.entries[i];
//             var entryAsBytes = entry.toBytes();
//             entriesAsByteArrays.push(entryAsBytes);
//         }       
         
//         for (var i = 0; i < entriesAsByteArrays.length; i++)
//         {
//             var entryAsBytes = entriesAsByteArrays[i];
//             fileAsBytes = fileAsBytes.concat(entryAsBytes);
//         }
         
//         var chunkSize = TarFile.ChunkSize;
         
//         var numberOfZeroChunksToWrite = 2;
         
//         for (var i = 0; i < numberOfZeroChunksToWrite; i++)
//         {
//             for (var b = 0; b < chunkSize; b++)
//             {
//                 fileAsBytes.push(0);
//             }
//         }
 
//         return fileAsBytes;
//     }

// }
 
// function TarFileEntry(header, dataAsBytes)
// {
//     this.header = header;
//     this.dataAsBytes = dataAsBytes;
// }
// {
//     TarFileEntry.fileNew = function(fileName, fileContentsAsBytes)
//     {
//         var header = new TarFileEntryHeader.fileNew(fileName, fileContentsAsBytes);
         
//         var entry = new TarFileEntry(header, fileContentsAsBytes);
         
//         return entry;
//     }
     
//     TarFileEntry.fromBytes = function(chunkAsBytes, reader)
//     {
//         var chunkSize = TarFile.ChunkSize;
     
//         var header = TarFileEntryHeader.fromBytes
//         (
//             chunkAsBytes
//         );
     
//         var sizeOfDataEntryInBytesUnpadded = header.fileSizeInBytes;    
 
//         var numberOfChunksOccupiedByDataEntry = Math.ceil
//         (
//             sizeOfDataEntryInBytesUnpadded / chunkSize
//         )
     
//         var sizeOfDataEntryInBytesPadded = 
//             numberOfChunksOccupiedByDataEntry
//             * chunkSize;
     
//         var dataAsBytes = reader.readBytes
//         (
//             sizeOfDataEntryInBytesPadded
//         ).slice
//         (
//             0, sizeOfDataEntryInBytesUnpadded
//         );
     
//         var entry = new TarFileEntry(header, dataAsBytes);
         
//         return entry;
//     }
     
//     TarFileEntry.manyFromByteArrays = function(entriesAsByteArrays)
//     {
//         var returnValues = [];
         
//         for (var i = 0; i < entriesAsByteArrays.length; i++)
//         {
//             var entryAsBytes = entriesAsByteArrays[i];
//             var entry = TarFileEntry.fileNew
//             (
//                 "File" + i, // hack - fileName
//                 entryAsBytes
//             );
             
//             returnValues.push(entry);
//         }
         
//         return returnValues;
//     }
     
//     // instance methods
 
//     TarFileEntry.prototype.download = function(event)
//     {
//         FileHelper.saveBytesAsFile
//         (
//             this.dataAsBytes,
//             this.header.fileName
//         );
//     }
     

     
//     TarFileEntry.prototype.toBytes = function()
//     {
//         var entryAsBytes = [];
     
//         var chunkSize = TarFile.ChunkSize;
     
//         var headerAsBytes = this.header.toBytes();
//         entryAsBytes = entryAsBytes.concat(headerAsBytes);
         
//         entryAsBytes = entryAsBytes.concat(this.dataAsBytes);
 
//         var sizeOfDataEntryInBytesUnpadded = this.header.fileSizeInBytes;   
 
//         var numberOfChunksOccupiedByDataEntry = Math.ceil
//         (
//             sizeOfDataEntryInBytesUnpadded / chunkSize
//         )
     
//         var sizeOfDataEntryInBytesPadded = 
//             numberOfChunksOccupiedByDataEntry
//             * chunkSize;
             
//         var numberOfBytesOfPadding = 
//             sizeOfDataEntryInBytesPadded - sizeOfDataEntryInBytesUnpadded;
     
//         for (var i = 0; i < numberOfBytesOfPadding; i++)
//         {
//             entryAsBytes.push(0);
//         }
         
//         return entryAsBytes;
//     }   
  
     
// }
 
// function TarFileEntryHeader
// (
//     fileName,
//     fileMode,
//     userIDOfOwner,
//     userIDOfGroup,
//     fileSizeInBytes,
//     timeModifiedInUnixFormat,
//     checksum,
//     typeFlag,
//     nameOfLinkedFile,
//     uStarIndicator,
//     uStarVersion,
//     userNameOfOwner,
//     groupNameOfOwner,
//     deviceNumberMajor,
//     deviceNumberMinor,
//     filenamePrefix
// )
// {
//     this.fileName = fileName;
//     this.fileMode = fileMode;
//     this.userIDOfOwner = userIDOfOwner;
//     this.userIDOfGroup = userIDOfGroup;
//     this.fileSizeInBytes = fileSizeInBytes;
//     this.timeModifiedInUnixFormat = timeModifiedInUnixFormat;
//     this.checksum = checksum;
//     this.typeFlag = typeFlag;
//     this.nameOfLinkedFile = nameOfLinkedFile;
//     this.uStarIndicator = uStarIndicator;
//     this.uStarVersion = uStarVersion;
//     this.userNameOfOwner = userNameOfOwner;
//     this.groupNameOfOwner = groupNameOfOwner;
//     this.deviceNumberMajor = deviceNumberMajor;
//     this.deviceNumberMinor = deviceNumberMinor;
//     this.filenamePrefix = filenamePrefix;
// }
// {
//     TarFileEntryHeader.SizeInBytes = 500;
 
//     // static methods
     
//     TarFileEntryHeader.default = function()
//     {
//         var returnValue = new TarFileEntryHeader
//         (
//             "".padRight(100, "\0"), // fileName
//             "100777 \0", // fileMode
//             "0 \0".padLeft(8), // userIDOfOwner
//             "0 \0".padLeft(8), // userIDOfGroup
//             0, // fileSizeInBytes
//             [49, 50, 55, 50, 49, 49, 48, 55, 53, 55, 52, 32], // hack - timeModifiedInUnixFormat
//             0, // checksum
//             TarFileTypeFlag.Instances.Normal,       
//             "".padRight(100, "\0"), // nameOfLinkedFile,
//             "".padRight(6, "\0"), // uStarIndicator,
//             "".padRight(2, "\0"), // uStarVersion,
//             "".padRight(32, "\0"), // userNameOfOwner,
//             "".padRight(32, "\0"), // groupNameOfOwner,
//             "".padRight(8, "\0"), // deviceNumberMajor,
//             "".padRight(8, "\0"), // deviceNumberMinor,
//             "".padRight(155, "\0") // filenamePrefix    
//         );      
         
//         return returnValue;
//     }
     
 
     
 
 
//     TarFileEntryHeader.fromBytes = function(bytes)
//     {
//         var reader = new ByteStream(bytes);
 
//         var fileName = reader.readString(100).trim();
//         var fileMode = reader.readString(8);
//         var userIDOfOwner = reader.readString(8);
//         var userIDOfGroup = reader.readString(8);
//         var fileSizeInBytesAsStringOctal = reader.readString(12);
//         var timeModifiedInUnixFormat = reader.readBytes(12);
//         var checksumAsStringOctal = reader.readString(8);
//         var typeFlagValue = reader.readString(1);
//         var nameOfLinkedFile = reader.readString(100);
//         var uStarIndicator = reader.readString(6);
//         var uStarVersion = reader.readString(2);
//         var userNameOfOwner = reader.readString(32);
//         var groupNameOfOwner = reader.readString(32);
//         var deviceNumberMajor = reader.readString(8);
//         var deviceNumberMinor = reader.readString(8);
//         var filenamePrefix = reader.readString(155);
//         var reserved = reader.readBytes(12);
 
//         var fileSizeInBytes = parseInt
//         (
//             fileSizeInBytesAsStringOctal.trim(), 8
//         );
         
//         var checksum = parseInt
//         (
//             checksumAsStringOctal, 8
//         );      
         
//         var typeFlags = TarFileTypeFlag.Instances._All;
//         var typeFlagID = "_" + typeFlagValue;
//         var typeFlag = typeFlags[typeFlagID];
 
//         var returnValue = new TarFileEntryHeader
//         (
//             fileName,
//             fileMode,
//             userIDOfOwner,
//             userIDOfGroup,
//             fileSizeInBytes,
//             timeModifiedInUnixFormat,
//             checksum,
//             typeFlag,
//             nameOfLinkedFile,
//             uStarIndicator,
//             uStarVersion,
//             userNameOfOwner,
//             groupNameOfOwner,
//             deviceNumberMajor,
//             deviceNumberMinor,
//             filenamePrefix
//         );
 
//         return returnValue;
//     }
// }   
 
// function TarFileTypeFlag(value, name)
// {
//     this.value = value;
//     this.id = "_" + this.value;
//     this.name = name;
// }
// {
//     TarFileTypeFlag.Instances = new TarFileTypeFlag_Instances();
 
//     function TarFileTypeFlag_Instances()
//     {
//         this.Normal         = new TarFileTypeFlag("0", "Normal");
//         this.HardLink       = new TarFileTypeFlag("1", "Hard Link");
//         this.SymbolicLink   = new TarFileTypeFlag("2", "Symbolic Link");
//         this.CharacterSpecial   = new TarFileTypeFlag("3", "Character Special");
//         this.BlockSpecial   = new TarFileTypeFlag("4", "Block Special");
//         this.Directory      = new TarFileTypeFlag("5", "Directory");
//         this.FIFO       = new TarFileTypeFlag("6", "FIFO");
//         this.ContiguousFile     = new TarFileTypeFlag("7", "Contiguous File");

//         this._All = 
//         [
//             this.Normal,
//             this.HardLink,
//             this.SymbolicLink,
//             this.CharacterSpecial,
//             this.BlockSpecial,
//             this.Directory,
//             this.FIFO,
//             this.ContiguousFile,
//         ];
 
//         for (var i = 0; i < this._All.length; i++)
//         {
//             var item = this._All[i];
//             this._All[item.id] = item;
//         }
//     }
// }   
 
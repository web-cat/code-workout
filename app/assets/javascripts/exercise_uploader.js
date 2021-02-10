var oldfileList =  document.getElementById("exercise_oldfileList").value.split(' ')
var oldfilesName = transferData("exercise_oldfileList")
var oldfilesNameBackup = oldfilesName.slice()
var oldfilesHashName = transferData("exercise_ownerships_res_name")
var totalList = oldfilesName.slice()
var table = document.getElementById("tablelist")
var path = "/uploads/resource_file/"
document.getElementById("exercise_fileList").value = totalList.toString()   

function applyHideAndShow(){
  if(totalList.length==0){
    $(filelist).addClass("hidden");
  }
  else{
    $(function () {
      $('#filelist').removeClass('hidden')
    })
  }
}


function transferData(tag){
  var data = []
  oldfileList =  document.getElementById(tag).value.split(' ')
  for( var i = 0; i < oldfileList.length; i++){ 
    if(oldfileList[i].replace(/\s/g, '').length){
      data.push(oldfileList[i])
    }
  }
  return data
}


function removeEle(arr,ele){
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


function deleteTableRow(row){
    var count = $('#tablelist tr').length;
    if(row == -1){
      for(var i = 1; i < count; i++){
        table.deleteRow(1)
      }
    }
    else{
      var entireRow= document.getElementById(row+"row")
      entireRow.remove()
    }
}



function isImage(filename){
  var filename = /[^.]+$/.exec(filename)
  if (String(filename).match(/(jpg|jpeg|png|gif)/g))
    return true
  return false
}


function addButtonListener(){
  document.getElementById("tablelist").addEventListener('click',function(e){
      if(e.target && e.target.id != null && e.target.id!= ""  && e.target.id.length<=2 ){
        var id = parseInt(e.target.id.charAt(0))
        var filename = document.getElementById(id+"name").innerHTML.trim()  
        totalList = removeEle(totalList, filename)
        if(oldfilesName.includes(filename)){
          oldfilesName = removeEle(oldfilesName, filename)
        }
        deleteTableRow(id)
        document.getElementById("exercise_fileList").value = totalList.toString()   
        applyHideAndShow()
    }
 });
}


function checkRes(fileName){
  var a = oldfilesNameBackup.indexOf(fileName)
  if(a != -1){
    return oldfilesHashName[a]
  }
  return null
}


function createTextAndButton(fileName,SizeList){
  deleteTableRow(-1)
  for (var i = 0; i < fileName.length; i++) {
    var exist = checkRes(fileName[i])
    var row = table.insertRow();
    row.setAttribute("id",(i+1)+"row")
    var imageOrNot = isImage(fileName[i])
    // Type info
    var cell0 = row.insertCell(0)
    if(imageOrNot){
      cell0.innerHTML = "Image"
    }
    else{
      cell0.innerHTML = "File"
    }
    // Thumbnail display
    var cell1 = row.insertCell(1)
    if(exist != null && imageOrNot){
      cell1.innerHTML = "<img class=\"img\" src=\""+path+exist+"\">"
    }
    else if (exist != null && !imageOrNot){
      cell1.innerHTML = "Not showable"
    }
    else{
      cell1.innerHTML = "Unknown"
    }
    //Name text
    var cell2 = row.insertCell(2)
    cell2.setAttribute("id",(i+1)+"name")
    cell2.innerHTML = fileName[i]
    //Pixel text
    var cell3 = row.insertCell(3)
    tempsrc = path+oldfilesHashName[i]
    if(exist != null && imageOrNot){
      var img = new Image()
      img.src = tempsrc
      cell3.innerHTML = img.width + 'x' + img.height+" pixels" 
    }
    else if (exist != null && !imageOrNot){
      //wait
    }
    else if (exist == null && imageOrNot){
      cell3.innerHTML = "0x0 pixels"
    }  else if (exist == null && !imageOrNot){
      var index = i - oldfilesName.length
      cell3.innerHTML =  SizeList[index] + " bytes"
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
  addButtonListener()
}


// upload button
$("#exercise_files").bind("change", function (e)
{
  totalList = oldfilesName.slice()
  var SizeList=[]
  var file = document.getElementById("exercise_files")
  for (var i = 0; i < file.files.length; i++) {
    filename = file.files[i].name
    if(totalList.indexOf(filename) === -1) {
      totalList.push(filename.trim())
      SizeList.push(file.files[i].size)
    }
  } 
  document.getElementById("exercise_fileList").value = totalList.toString()  
  applyHideAndShow()
  createTextAndButton(totalList,SizeList)
});


applyHideAndShow()
createTextAndButton(oldfilesName,"old")
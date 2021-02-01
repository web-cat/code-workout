var allfiles = []
var oldfiles = []
var oldfileList
var oldfiles
checkoudFile()

function checkoudFile(){
  oldfiles = []
  oldfileList =  document.getElementById("exercise_oldfileList").value.split(' ')
  for( var i = 0; i < oldfileList.length; i++){ 
    if(oldfileList[i].replace(/\s/g, '').length){
      oldfiles.push(oldfileList[i])
    }
    createTextAndButton(oldfiles)
  }
}


function removeEle(arr,ele){
	arr = arr.split(",")
  for( var i = 0; i < arr.length; i++){ 
    if ( arr[i] == ele.trim()) { 
        arr.splice(i, 1); 
    }
  }
  return arr
}

function addButtonListener(allfiles){

  document.querySelector('#fileName').addEventListener('click', function(event) {
      allfiles = document.getElementById("exercise_fileList").value
      allfiles += oldfileList 
      var text= document.getElementById(event.target.id.match(/\d*/g)[0])
      allfiles = removeEle(allfiles, text.innerHTML.toString().trim())
      var button = document.getElementById(event.target.id)
      text.nextSibling.remove()
      text.remove()
      button.remove()
      document.getElementById("exercise_fileList").value = allfiles.toString()  
      document.getElementById("exercise_oldfileList").value = allfiles.toString()  
  });

}

// update file name and delete button
function createTextAndButton(allfiles){
  $("#fileName").empty()
  for (var i = 0; i < allfiles.length; i++) {
    var button = document.createElement("button");
    button.setAttribute("id", i+"button");
    button.setAttribute("type", "button");
    button.setAttribute("style", "height:23px;width:108px;text-align: center");
    button.innerHTML = "Delete File";
    $("#fileName").append(button);
    $("#fileName").append("<span id="+i+" label="+allfiles[i]+">"+" "+allfiles[i]+"</span>");
    $("#fileName").append("<br>");
  }
  addButtonListener(allfiles)
}

// listener for upload button
$("#exercise_files").bind("change", function (e)
{
  allfiles = []
  checkoudFile()
  for (var i of oldfiles) {
    allfiles.push(i);
  } 
  var file = document.getElementById("exercise_files")
  for (var i = 0; i < file.files.length; i++) {
    filename = file.files[i].name
    if(allfiles.indexOf(filename) === -1) {
      allfiles.push(filename.trim()); 
    }
  } 
  document.getElementById("exercise_fileList").value = allfiles.toString()     
  createTextAndButton(allfiles)
});

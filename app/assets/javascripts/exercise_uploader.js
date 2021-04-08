var file_orig_name =  document.getElementById("exercise_file_orig_name").value.split(/[ ,]+/)
var file_hash_name =  document.getElementById("exercise_file_hash_name").value.split(/[ ,]+/)
var table = document.getElementById("tablelist")
var path = "/uploads/resource_file/"

function removeDuplicates(array) {
  return array.filter((a, b) => array.indexOf(a) === b)
};

function apply_hide_and_show(){
  if(file_orig_name.length==0 ||(file_orig_name.length==1&& file_orig_name[0]=="") ){
    $('#filelist').addClass("hidden");
  }
  else{
    $(function () {
      $('#filelist').removeClass('hidden')
    })
  }
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
        var id = parseInt(e.target.id)
        file_orig_name.splice(id-1, 1)
        file_hash_name.splice(id-1, 1)
        document.getElementById("exercise_file_orig_name").value = file_orig_name.toString() 
        document.getElementById("exercise_file_hash_name").value = file_hash_name.toString() 
        delete_table_row(id) 
        apply_hide_and_show()
    }
 });
}


function create_text_and_button(file_orig_name,file_hash_name){
  console.log(file_orig_name)
  console.log(file_hash_name)
  console.log("end create")
  delete_table_row(-1)
  for (var i = 0; i < file_orig_name.length; i++) {
    var hash_name = file_hash_name[i]
    var row = table.insertRow();
    row.setAttribute("id",(i+1)+"row")
    var image_or_not = is_image(file_orig_name[i])
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
    if( image_or_not){
      cell1.innerHTML = "<img class=\"img\" src=\""+path+hash_name+"\">"
    }
    else if ( !image_or_not){
      cell1.innerHTML = "Not showable"
    }
    else{
      cell1.innerHTML = "Unknown"
    }
    //Name text
    var cell2 = row.insertCell(2)
    cell2.setAttribute("id",(i+1)+"name")
    cell2.innerHTML = file_orig_name[i]
    //Pixel text
    var cell3 = row.insertCell(3)
    var temp_src = path+file_hash_name[i]
    if(image_or_not){
      var img = new Image()
      img.src = temp_src
      cell3.innerHTML = img.width + 'x' + img.height+" pixels" 
    }
    else {
      cell3.innerHTML =  ""
    }
    var cell4 = row.insertCell(4)
    cell4.innerHTML = "<button class=\"btn btn-link glyphicon glyphicon-trash fa-lg\" id="+(i+1)+" type=\"button\"></button>"
  }
  add_button_listener()
}


file_orig_name = removeDuplicates(file_orig_name)
file_hash_name = removeDuplicates(file_hash_name)
apply_hide_and_show()
create_text_and_button(file_orig_name,file_hash_name)



// **************** upload button *****************************
document.getElementById("exercise_files").onchange = function() {
  $(this).parents('form').submit();
};

// **************** upload exercise description ***************
document.getElementById("exercise_description").onchange = function() {
  $(this).parents('form').submit();
};


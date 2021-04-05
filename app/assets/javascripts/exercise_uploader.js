var old_file_list =  document.getElementById("exercise_oldfileList").value.split(' ')
var old_files_name = transfer_data("exercise_oldfileList")
var old_files_name_backup = old_files_name.slice()
var old_files_hash_name = transfer_data("exercise_ownerships_res_name")
var total_list = old_files_name.slice()
var table = document.getElementById("tablelist")
var path = "/uploads/resource_file/"
document.getElementById("exercise_fileList").value = total_list.toString()   



console.log(old_files_name)
console.log(old_files_hash_name)
console.log(old_files_name_backup)
console.log(total_list)


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
      cell3.innerHTML =  ""
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
  $(this).parents('form').submit();
};


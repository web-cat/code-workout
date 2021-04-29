$(document).ready(function()
{
  var attached_files = JSON.parse(document.getElementById('exercise_attached_files').value)

  function show_files_if_any()
  {
    if (attached_files.length > 0)
    {
      $('#filelist').removeClass('hidden')
    }
    else
    {
      $('#filelist').addClass('hidden')
    }
  }


  function remove_duplicate_resource( prop)
  {
    var newArray = [];
    var lookupObject  = {};
    for(var i in attached_files) {
       lookupObject[attached_files[i][prop]] = attached_files[i]
    }
    for(i in lookupObject) {
        newArray.push(lookupObject[i])
    }
    attached_files = newArray
  }

  function is_image(file_name)
  {
    return file_name.match(/(jpg|jpeg|png|gif)$/i)
  }


  function update_attached_files()
  {
    document.getElementById('exercise_attached_files').value =
      JSON.stringify(attached_files)
    show_files_if_any()
  }


  function remove_attachment(index)
  {
    if (index !== undefined) attached_files.splice(index, 1);
    document.getElementById((index + 1) + "row").remove()
  }


  function add_row_for_attachment(index)
  {
    var f = attached_files[index]
    var row = document.getElementById("tablelist").insertRow();
    row.setAttribute("id",(index + 1) + "row")
    const fname = f.name
    const is_img = is_image(fname)
    const file_url = f.url
    const x_dimension = f.x_dimension
    const y_dimension = f.y_dimension
    const fsize = f.size
    var col = 0
    // Type info
    var cell = row.insertCell(col++)

    // file name in col 1
    cell.setAttribute("id", (index + 1) + "name")
    cell.innerHTML = fname

    // Thumbnail in col 2
    cell = row.insertCell(col++)
    if (is_img)
    {
      if (file_url != null)
      {
        cell.innerHTML = '<img class="thumb" src="' + file_url + '"/>'
      }
      else
      {
        cell.innerHTML = '(uploaded on save)'
      }
    }

    // dimensions in col 3
    cell = row.insertCell(col++)
    if (file_url != null)
    {
      if (is_img)
      {
        cell.innerHTML = x_dimension + 'x' + y_dimension
      }
    }

    // file size in col 4
    cell = row.insertCell(col++)
    cell.innerHTML = fsize + " Kilobytes"

    // Delete Button
    cell = row.insertCell(col++)
    var btn = document.createElement('button')
    btn.className = 'btn btn-default'
    btn.innerHTML = '<i class="fa fa-trash-o icon-fixed-width"></i>'
    btn.addEventListener('click', function(e) {
      e.preventDefault()
      remove_attachment(index)
      update_attached_files()
      show_files_if_any()
      console.log(attached_files)
    })
    cell.appendChild(btn)
    
  }


  remove_duplicate_resource("name");
  for (var i = 0; i < attached_files.length; i++)
  {
    add_row_for_attachment(i)
  }
  console.log("test")
  console.log(attached_files)
  document.getElementById('exercise_attached_files').value = JSON.stringify(attached_files)
  console.log(  document.getElementById('exercise_attached_files').value)
  show_files_if_any()


  document.getElementById("exercise_files").onchange = function() {
    $(this).parents('form').submit();
  }


  document.getElementById("exercise_description").onchange = function() {
    $(this).parents('form').submit();
  }
});
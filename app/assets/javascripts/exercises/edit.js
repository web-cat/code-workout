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
    attached_files[index].deleted = true
    document.getElementById((index + 1) + "row").remove()
  }


  function remove_uploads()
  {
    for (var i = 0; i < attached_files.length; i++)
    {
      var f = attached_files[i]
      if (!f.uploaded && !f.deleted)
      {
        remove_attachment(i)
      }
    }
  }

  function add_upload(fname)
  {
    attached_files.push(
      {
        'name': fname,
        'uploaded': false,
        'deleted': false
      }
    )
    add_row_for_attachment(attached_files.length - 1)
  }


  function add_row_for_attachment(index)
  {
    var f = attached_files[index]
    if (!f.deleted)
    {
      var row = document.getElementById("tablelist").insertRow();
      row.setAttribute("id",(index + 1) + "row")
      var fname = f.name
      var is_img = is_image(fname)
      var file_url = f.url
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
          var img = new Image()
          img.src = file_url
          cell.innerHTML = img.width + 'x' + img.height
        }
      }

      // Delete Button
      cell = row.insertCell(col++)
      // cell.innerHTML = '<button class="btn btn-default" id="' + (i + 1) +
      //  'btn" type="button"><i class="fa fa-trash-o icon-fixed-width"></i></button>'
      var btn = document.createElement('button')
      btn.className = 'btn btn-default'
      btn.innerHTML = '<i class="fa fa-trash-o icon-fixed-width"></i>'
      btn.addEventListener('click', function(e) {
        e.preventDefault()
        remove_attachment(index)
        update_attached_files()
      })
      cell.appendChild(btn)
    }
  }


  // upload button
  $('#exercise_files').bind('change', function (e)
  {
    remove_uploads()
    var file = document.getElementById('exercise_files')
    for (var i = 0; i < file.files.length; i++)
    {
      add_upload(file.files[i].name)
    }
    update_attached_files()
    alert("attached_files = '" + JSON.stringify(attached_files) + "'\n"
      + "file.files = '" + JSON.stringify(file.files) + "'\n"
    )
  });


  for (var i = 0; i < attached_files.length; i++)
  {
    add_row_for_attachment(i)
  }
  show_files_if_any()
});

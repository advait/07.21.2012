
# GET home page

exports.index = (req, res) ->
  console.log 'USER'.red, req.session.auth.facebook.user
  res.render('index', { title: 'Express' })

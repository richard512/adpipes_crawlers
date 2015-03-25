_log = (message)->
  #console.log message

###
 ---------    string_parse.toInt   ----------

Error: Parsing error in string_parser.toInt(1000,768.878) argument is like float number
toInt    '5e4' =   50000
toInt    '5E-4' =   0.0005
toInt    '$25.7' =   257
toInt    '30,000,222' =   30000222
toInt    '32%' =   32
toInt    '1 000,76' =   100076
toInt    35 =   35   (argument is number)

 ---------    string_parse.toFloat   ----------

toFloat    '1000,768.878' =   1000768.878
toFloat    '5e4' =   50000
toFloat    '5E-4' =   0.0005
toFloat    '$25.7' =   25.7
toFloat    '30,000,222' =   30000222
toFloat    '32%' =   32
toFloat    '1 000,76' =   100076
toFloat    35 =   35   (argument is number)


 ---------    string_parse.toFloatWithComma   ----------

toFloatWithComma    '1000,768.878' =   1000.768878 #todo: must be error
toFloatWithComma    '5e4' =   50000
toFloatWithComma    '5E-4' =   0.0005
toFloatWithComma    '$25.7' =   257
Error: Parsing error in string_parser.toFloatWithComma(30,000,222)
toFloatWithComma    '32%' =   32
toFloatWithComma    '1 000,76' =   1000.76
toFloatWithComma    35 =   35   (argument is number)


 ---------          All functions        ----------
Error: Parsing error in string_parser.toFloatWithComma(1-3)
Error: Parsing error in string_parser.toFloatWithComma('')
Error: Parsing error in string_parser.toFloatWithComma(4 undefined 0)
Error: Parsing error in string_parser.toFloatWithComma(Infinity)
Error: Parsing error in string_parser.toFloatWithComma(NaN)
Error: Parsing error in string_parser.toFloatWithComma(null)
Error: Parsing error in string_parser.toFloatWithComma(undefined)




###
isntRealNumber = (number)->
  number isnt number or number is Infinity or number is -Infinity #check if str is NaN or Infinity

str_to_number = (str, filter, func_name, replacer) ->
  if typeof str is 'number'
    if isntRealNumber str
      throw new Error("Parsing error in string_parser.#{func_name}(#{str})")
    _log("#{func_name}    #{str} =   #{str}   (argument is number)")
    return str
  if str is null or str is undefined
    throw new Error("Parsing error in string_parser.#{func_name}(#{str})")
  if str.replace(' ', '').toLowerCase() is 'n\a' or str.replace(' ', '').toLowerCase() is 'n/a'
    return 0
  if func_name is 'toInt' and str.indexOf(',') isnt -1 and str.indexOf('.') isnt -1
    throw new Error("Parsing error in string_parser.#{func_name}(#{str}) argument is like float number")
  ciphers = str.replace(filter, '')
  if ciphers is '-'
    return 0
  if replacer
    ciphers = replacer(ciphers)
  countOfDot = ciphers.split('.').length - 1
  if ciphers is '' or countOfDot > 1 or (countOfDot > 0 and ciphers.length <= 2)
    throw new Error("Parsing error in string_parser.#{func_name}('#{str}')")
  result = +ciphers
  if isntRealNumber result
    throw new Error("Parsing error in string_parser.#{func_name}(#{str})")
  _log("#{func_name}    '#{str}' =   #{result}")
  return result;

module.exports =
  toInt: (str) ->
    str_to_number(str, /[^0-9eE-]/g, 'toInt')

  toFloat: (str) ->
    str_to_number(str, /[^0-9eE.-]/g, 'toFloat')

  toFloatWithComma: (str) ->
    str_to_number(str, /[^0-9eE,-]/g, 'toFloatWithComma', (str)-> str.replace(',', '.'))
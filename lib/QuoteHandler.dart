import 'dart:convert';
import 'dart:io';
import 'dart:math';

List<String> getRandomQuote(String guildID){
  var quote = <String, dynamic>{'content': '', 'author': '', 'date': ''};
  try{
    var r = Random(DateTime.now().millisecondsSinceEpoch);
    var quotesJson = File('$guildID.json');
    var quotesString = quotesJson.readAsStringSync();
    List<dynamic> quotes = jsonDecode(quotesString);
    quote = quotes[1 + r.nextInt(quotes.length - 1)];
  }
  catch(e){
    //print(e);
    return [noQuoteError, '<@722092710256967730>', DateTime.now().toString()];
  }

  return [quote['content'], quote['author'], quote['date'] ?? ''];
}

List<String> getSearchQuote(String guildID, String query, {int which = 0}){
  var quote = <String, dynamic>{'content': '', 'author': '', 'date': ''};

  if(query == 'null')
  {
    return ['Please put quotations around the quote you would like to search for','<@722092710256967730>', DateTime.now().toString()];
  }

  try{
    var quotesJson = File('$guildID.json');
    var quotesString = quotesJson.readAsStringSync();
    List<dynamic> quotes = jsonDecode(quotesString);
    quote = quotes.where((q) => q['content'].toString().toLowerCase().contains(query.toLowerCase())).elementAt(which);
  }
  catch(e){
    if(e.runtimeType == FileSystemException) {
      return [noQuoteError, '<@722092710256967730>', DateTime.now().toString()];
    } else if (e.runtimeType == RangeError) {
      return ['**I can''t find any quotes like that**', '<@722092710256967730>', DateTime.now().toString()];
    } else if (e.runtimeType == IndexError)
    {
      return ['**I can''t find any quotes like that**', '<@722092710256967730>', DateTime.now().toString()];
    }
    print(e.toString());
    return [critError, '<@722092710256967730>', DateTime.now().toString()];
  }
  return [quote['content'], quote['author'], quote['date'] ?? ''];  
}

List<String> addQuote(String guildID, String quote, String author){
  var quoteMap = <String, dynamic>{'content': quote, 'author': '<@${author}>', 'date': DateTime.now().toString(), 'length': quote.length};
  
  print(quote);

  if(quote == 'null')
  {
    return ['Please put quotations around the quote you would like to add','<@722092710256967730>', DateTime.now().toString()];
  }

  try{
    var quotesJson = File('$guildID.json');
    var quotesString = quotesJson.readAsStringSync();
    List<dynamic> quotes = jsonDecode(quotesString);
    quotes.add(quoteMap);

    File('$guildID.json').writeAsStringSync(jsonEncode(quotes), mode:FileMode.writeOnly);
  }
  catch(e){
    if(e.runtimeType == FileSystemException) {

      var quotes = <dynamic>[];

      File('$guildID.json').create(recursive: true).then((value) => {
        //print(quoteMap),
        quotes.add({'SD': DateTime.now().toString()}),
        quotes.add(quoteMap),
        File('$guildID.json').writeAsString(jsonEncode(quotes))
      });

      return [quote,'<@${author}>', DateTime.now().toString()];
    } else {
      print(e.toString());
      return [critError, '<@722092710256967730>', DateTime.now().toString()];
    }
  }
  return [quote,'<@${author}>', DateTime.now().toString()];
}

List<String> updateStartDate(String guildID, String startDate){
  try{
    var quotesJson = File('$guildID.json');
    var quotesString = quotesJson.readAsStringSync();
    List<dynamic> quotes = jsonDecode(quotesString);
    quotes[0]['SD'] = DateTime.parse(startDate).toString();

    File('$guildID.json').writeAsStringSync(jsonEncode(quotes), mode:FileMode.writeOnly);
  }
  catch(e){
    if(e.runtimeType == FileSystemException) {
      var quotes = <dynamic>[];
      File('$guildID.json').create(recursive: true).then((value) => {
        quotes.add({'SD': DateTime.now().toString()}),
        File('$guildID.json').writeAsString(jsonEncode(quotes))
      });
    } else if(e.runtimeType == FormatException){
      return ['**LOG:** Invalid date format', '<@722092710256967730>', DateTime.now().toString()];
    } else {
      print(e.toString());
      return [critError, '<@722092710256967730>', DateTime.now().toString()];
    }
  }

  return ['Successfully updated starting date to **${DateTime.parse(startDate).toString()}**','<@722092710256967730>', DateTime.now().toString()];
}



String noQuoteError = 'There are no quotes for this server, add quotes using the *%quote add "quote" @author* command. \n\n**Example:** *%quote add "When le redditor is extra pog" <@148078506578935808>*';
String critError = 'An error has occured, please contact <@148078506578935808>';

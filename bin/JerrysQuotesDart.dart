import 'dart:math';
import 'package:JerrysQuotesDart/QuoteHandler.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commander/commander.dart';
import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) {

  var settingsJson = File('settings.json');
  var settingsString = settingsJson.readAsStringSync();
  Map<String, dynamic> settings = jsonDecode(settingsString);

  var bot = Nyxx(settings['TOKEN'], 32265);
  
  bot.onReady.listen((event) {
    print("Ready to Eat Rocks and Burn Chalk, and I'm all out of Chalk");
  });

  var c = Commander(bot, prefix: '%');

    c.registerCommand('help', (context, message) => context.reply(content: c.commands.map((e) => '${e.getFullCommandName()} ${e.aliases}')));

    var reg = RegExp(r'(?<=")[^"]+(?=")', caseSensitive: false);
    var regNum = RegExp(r'(\d+)');

    var quoteGroup = CommandGroup(name: 'quote', aliases: ['q']);
    quoteGroup.registerSubCommand('random', (context, message) => context.sendMessage(embed: buildEmbed(getRandomQuote(context.guild.id.toString()), context.guild.id.toString())));
    quoteGroup.registerSubCommand('search', (context, message) => context.sendMessage(embed: buildEmbed(getSearchQuote(context.guild.id.toString(), reg.stringMatch(message).toString(), which: int.parse(regNum.allMatches(message).isNotEmpty ? regNum.allMatches(message).last.group(0).toString() : '0')), context.guild.id.toString())));
    quoteGroup.registerSubCommand('add', (context, message) => context.sendMessage(embed: buildEmbed(addQuote(context.guild.id.toString(), reg.stringMatch(message).toString(), context.message.mentions.first.id.toString()), context.guild.id.toString())));

    c.registerCommand('setStartDate', (context, message) => {
      context.sendMessage(embed: buildEmbed(updateStartDate(context.guild.id.toString(), context.message.content.split(' ')[1]), context.guild.id.toString()))
    });

    c.registerCommandGroup(quoteGroup);

    bot.onMessageReceived.listen((MessageReceivedEvent event) {
      
    });
}

EmbedBuilder buildEmbed(List<String> quoteData, String guildID){

  var quote = quoteData[0];
  var author = quoteData[1];
  var date = quoteData[2];

  var startDate = '';

  try {
    startDate = jsonDecode(File('${guildID}.json').readAsStringSync())[0]['SD'] ?? DateTime.now().toString();
  } catch (e) {
    startDate = DateTime.now().toString();
  }
  

  var day = DateTime.now().difference(DateTime.parse(startDate));

  var foot = EmbedFooterBuilder();
  var auth = EmbedAuthorBuilder();
  var field = EmbedFieldBuilder();

  auth.name = 'Jerry 🌵';
  auth.iconUrl = 'https://cdn.discordapp.com/avatars/148078506578935808/2a29f113d712567300a235279c9bdb3d.png';
  auth.url = 'http://jerbb.com';


  field.name = 'Author';
  field.content = author;

  foot.text = 'Woah! So cool! [http://jerbb.com]';
  foot.iconUrl = 'https://i.imgur.com/7NWkUf1.jpg';
  
  var embed = EmbedBuilder();

  embed.author = auth;
  embed.footer = foot;
  embed.fields.addAll([field]);
  embed.description = quote;

  day.inDays != 0 ? embed.title = 'QOTD _Day ${day.inDays}:_' : embed.title = 'QOTD:';

  embed.url = 'http://jerbb.com';

  var _random = Random();
  embed.color = DiscordColor.fromRgb(_random.nextInt(255), _random.nextInt(255), _random.nextInt(255));

  embed.timestamp = DateTime.tryParse(date);

  return embed;
}
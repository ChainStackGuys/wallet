
import 'dart:math';

import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/crypto.dart';

import 'package:provider/provider.dart';
import 'package:youwallet/model/wallet.dart' as walletModel;
import 'package:youwallet/global.dart';
import 'package:youwallet/util/http_server.dart';

//abstract class TokenService {
//  String generateMnemonic();
//  String maskAddress(String address);
//  String getPrivateKey(String mnemonic);
//  Future<EthereumAddress> getPublicAddress(String privateKey);
//  Future<bool> setupFromMnemonic(String mnemonic);
//  Future<bool> setupFromPrivateKey(String privateKey);
//  String entropyToMnemonic(String entropyMnemonic);
//}

class TokenService {
//  IConfigurationService _configService;
//  AddressService(this._configService);
  String customeAgent = "";

  /// 交易所合约地址
//  static final contractAddress= "0x7E999360d3327fDA8B0E339c8FC083d8AFe6A364";

  // 获取助记词
  static String generateMnemonic() {
    String randomMnemonic = bip39.generateMnemonic();
    return randomMnemonic;
  }


//  static String getPrivateKey(String randomMnemonic) {
//
//    String hexSeed = bip39.mnemonicToSeedHex(randomMnemonic);
//
//    KeyData master = ED25519_HD_KEY.getMasterKeyFromSeed(hexSeed);
//    return HEX.encode(master.key);
//  }

  static  maskAddress(String address) {
    if (address.length > 0) {
      return "${address.substring(0, 8)}...${address.substring(address.length - 12, address.length)}";
    } else {
      return address;
    }
  }

  String entropyToMnemonic(String entropyMnemonic) {
    return bip39.entropyToMnemonic(entropyMnemonic);
  }


   // 助记词转私钥Private Key
  static String getPrivateKey(String mnemonic) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final child1 = root.derivePath("m/44'/60'/0'/0/0");
    return bytesToHex(child1.privateKey);
  }

  static Future<EthereumAddress> getPublicAddress(String privateKey) async {
    final private = EthPrivateKey.fromHex(privateKey);
    final address = await private.extractAddress();
    return address;
  }


  /// 获取指定钱包的余额，这里获取的是ETH的余额
  static Future<String> getBalance(String address) async {
      String rpcUrl = Global.getBaseUrl();
      final client = Web3Client(rpcUrl, Client());
      EtherAmount balance = await client.getBalance(EthereumAddress.fromHex(address));
      double b = balance.getValueInUnit(EtherUnit.ether);
      return  b.toStringAsFixed(4);
  }

  static Future<String> getNetWork() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String network =  prefs.getString('network');
    String myKey = 'v3/37caa7b8b2c34ced8819de2b3853c8a2';
    return 'https://' + network + '.infura.io/' + myKey;
  }

  /// 搜索指定token
  static Future<String> getTokenName(String address) async {
    Map params = {
      "to": address,
      "data": "0x95d89b41"
    };
    var response = await Http().post(params: params);
    String res = response['result'];
    String name = res.replaceFirst('0x', '');
    String nameString = '';
    for(var i = 0; i < name.length; i = i + 2) {
      String subStr = name.substring(i, i+2);
      if (subStr != "00" && subStr != "20" && subStr != "03") {
        String str = String.fromCharCode(int.parse(name.substring(i, i+2), radix: 16));
        nameString = nameString + str;
      }
    }
    return nameString;
  }

  /// https://yq.aliyun.com/articles/600706/
  /// 这里获取的是指定token的余额
  /// 这里还要考虑小数点的问题，正常情况下token都是18位小数，特殊情况下有12位小数存在
  /// 计算balance，需根据当前token的小数点来除
  /// 当前还是固定的18位
  static Future<String> getTokenBalance(Map token) async {
    String myAddress = Global.getPrefs("currentWallet");
    Map params = {
      "to": token['address'],
      "data": Global.funcHashes['getTokenBalance()'] + myAddress.replaceFirst('0x', '').padLeft(64, '0')
    };
    var response = await Http().post(params: params);
    double balance = BigInt.parse(response['result'])/BigInt.from(pow(10, token['decimals']));
    if (balance == 0.0) {
      return '0';
    } else {
      return balance.toStringAsFixed(3);
    }
  }

  /// 获取代币的小数位数
  static Future<int> getDecimals(String address) async {
    Map params = {
      "to": address,
      "data": Global.funcHashes['getDecimals()']
    };
    var response = await Http().post(params: params);
    return int.parse(response['result'].replaceFirst("0x",''), radix: 16);
  }


  /* 获取授权代理额度 - R
   * owner: 授权人账户地址，就是用户钱包地址
   * spender: 代理人账户地址,就是proxy的合约地址
   * 拼接postData，每次都很长，如果更优雅的拼接postData呢
   * 返回值
   * uint256 value: 代理额度
   * */
  static Future<String> allowance(context,String token) async{
    String myAddress = Provider.of<walletModel.Wallet>(context).currentWalletObject['address'];
    String postData = Global.funcHashes['allowance'] + myAddress.replaceFirst('0x', '').padLeft(64, '0') + Global.proxy.replaceFirst('0x', '').padLeft(64, '0');
    Map params = {
      "to": token,
      "data": postData
    };
    var response = await Http().post(params: params);
    return BigInt.parse(response['result']).toString();
  }

  static formatParam(String para) {
    para = para.replaceFirst('0x', '');
    String str = '';
    int i = 0;
    while(i < 64 - para.length)
    {
      str = str + '0';
      i++;
    }
    return str + para;
  }


}

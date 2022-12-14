//
//  CoinDataService.swift
//  Arfinance
//
//  Created by Muhammad Arfan on 18/10/22.
//

import Foundation
import Combine
import SwiftUI

class CoinService {
	@Published var collection : [Coin] = [] ;
	
	private let fileManager = LocalFileManager.instance ;
	private let subcriptions : Subscription = Subscription()
	class Subscription {
		var coin : AnyCancellable?
	}
	
	init () {
		self.fetch()
	}
	
	public func fetch () {
		guard let url = URL(string: API.Coin.data) else {return}
		
		self.subcriptions.coin = NetworkManager.request(url: url)
			.retry(3)
			.decode(type: [Coin].self, decoder: JSONDecoder())
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: NetworkManager.handleCompletion, receiveValue: {[weak self] (coins : [Coin]) in
				guard let self = self else {return};
				self.collection = coins;
				self.subcriptions.coin?.cancel()
			})
	}
	
	public func fetchLogo (url : URL) async -> UIImage? {
		if let logo : UIImage = self.fileManager.get(imageName: url.path.components(separatedBy: "/").last! , dirName: "coin_images") {
			return logo ;
		}
		
		do {
			let (data, _) = try await URLSession.shared.data(from: url);
			let logo = UIImage(data: data);
			if let logo = logo {
				self.fileManager.save(image: logo, imageName: url.path.components(separatedBy: "/").last!, dirName: "coin_images")
			}
			return logo
		} catch  {
			print(error.localizedDescription)
			return nil ;
		}
	}
	
	public func fetchMarket () async -> CoinMarket? {
		let url = URL(string: API.Coin.globalMarket)! ;
		
		do {
			let (data, _) = try await URLSession.shared.data(from: url);
			let coinGlobalMarket = try JSONDecoder().decode(CoinGlobalMarket.self, from: data);
			return coinGlobalMarket.data ;
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}
	
	public func fetchDetail (coin : Coin) async -> CoinDetail? {
		let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false")! ;
		
		do {
			let (data, _) = try await URLSession.shared.data(from: url);
			var coinDetail = try JSONDecoder().decode(CoinDetail.self, from: data);
			coinDetail.coin = coin ;
			return coinDetail ;
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}
	
	
}

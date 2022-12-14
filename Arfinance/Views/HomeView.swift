//
//  HomeView.swift
//  Arfinance
//
//  Created by Muhammad Arfan on 16/10/22.
//

import SwiftUI

struct HomeView: View {
	
	@EnvironmentObject private var vm : HomeVM ;
	
//	@State private var showPortfolio: Bool = false // animate right
//	@State private var showPortfolioSheet: Bool = false // new sheet
	@State private var showCoinDetail : Bool = false ;
	@State private var selectedCoin : Coin? = nil ;
	
	@State private var sortChevronDirection : ChevronDirectionEnum = .down ;
	
	var body: some View {
		ZStack{
			Color.theme.background.ignoresSafeArea()
			
			VStack{
				HomeHeaderComponent()
					.padding()
					.environmentObject(vm)
				
				CoinStatisticHighlightComponent(coinStatistics: self.$vm.coinStatistics)
				
				SearchBarComponent(keyword: self.$vm.keyword)
					.padding(.all , 6)
				
				HStack{
					SortButtonComponent(title: "Coin", chevronDirection: self.$sortChevronDirection) { chevronDirection in
						self.vm.coinSortOption = chevronDirection == .up ? .rankHighest : .rankLowest ;
					}
					Spacer()
					if (self.vm.showPortfolio) {
						SortButtonComponent(title: "Holding", chevronDirection: self.$sortChevronDirection) { chevronDirection in
							self.vm.coinSortOption = chevronDirection == .up ? .holdingHighest : .holdingLowest ;
						}
					}
					SortButtonComponent(title: "Price", chevronDirection: self.$sortChevronDirection) { chevronDirection in
						self.vm.coinSortOption = chevronDirection == .up ? .priceHighest : .priceLowest ;
					}
				}
				.font(.caption)
				.foregroundColor(.theme.secondaryText)
				.padding(.horizontal)
				
				Group{
					if self.vm.showPortfolio {
						if (self.vm.portfolioCoins.isEmpty && !self.vm.keyword.isEmpty) {
							Text("No results for \"\(self.vm.keyword)\"")
								.font(.callout)
								.foregroundColor(.theme.accent)
								.fontWeight(.medium)
								.multilineTextAlignment(.center)
								.padding(50)
						} else if (self.vm.portfolioCoins.isEmpty) {
							Text("You haven't added any coin to your portflio")
								.font(.callout)
								.foregroundColor(.theme.accent)
								.fontWeight(.medium)
								.multilineTextAlignment(.center)
								.padding(50)
						} else {
							CoinListComponent(coins: self.$vm.portfolioCoins, showHoldingColumn : true) { coin in
								self.selectedCoin = coin ;
								self.showCoinDetail.toggle();
							}
						}
					} else {
						CoinListComponent(coins: self.$vm.coins) { coin in
							self.selectedCoin = coin ;
							self.showCoinDetail.toggle();
						}
					}
				}
				.sheet(isPresented: self.$showCoinDetail) {
					CoinDetailView(coin: self.$selectedCoin)
				}
				
				Spacer(minLength: 6)
			}
		}
	}
	
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
			.environmentObject(HomeVM())
	}
}

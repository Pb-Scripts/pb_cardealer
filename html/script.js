$(".container").hide()

let vehicles
let Max
let page = 1
let price
let model
let id
let nome

function Close() {
    $(".container").hide()
    $.post('https://pb_cardealer/FecharC', JSON.stringify({tipo:id}))
}

function PageChange() {
    $(".carL").remove()
    $(".colorList").remove()
    $(".listComp").remove()
    $(".list").remove()
    $(".listE").remove()
    $(".container").append('<ul class ="carL"> <div class="topList"><i class="fas fa-car-side"></i>LISTA DE VEÍCULOS<div class="risco"></div><i class="fas fa-angle-left"></i><i class="fas fa-angle-right"></i></div></ul>')
    for (i = ((page - 1) * 7); i <= 7 * page; i++) {
        if (vehicles[i] !== undefined) {
            $(".container").append('<li class="listE" nome ="' + vehicles[i].name +'" price = "' + vehicles[i].price + '"id="' + vehicles[i].model + '">' + vehicles[i].name + '<p>' + vehicles[i].price + '€</p></li>')
        }
    }
    $(".container").append('<div class="colorList"><i class="fas fa-dollar-sign"></i>COMPRAR VEÍCULO<div class="risco3"></div></div><li class="listComp">Comprar</li><li class="list">Testar</li>')
    ClickPage()
}

window.addEventListener("message", function (event) {
    if (event.data.type === "cars") {
        let cars = event.data.cars
        let max = event.data.max
        id = event.data.id

        Max = Math.ceil(max / 8);
        vehicles = cars
        page = 1
        PageChange()
        $(".container").show()
    } else if (event.data.type === "close") {
        Close()
    }
})

function ClickPage () {
    $(".fa-angle-left").click(function(){
        if (page > 1) {
            page -= 1
            PageChange()
        }
    })
    
    $(".fa-angle-right").click(function(){
        if (page < Max) {
            page += 1
            PageChange()
        }
    })

    $(".listE").click(function(){
        model = $(this).attr('id')
        price = $(this).attr('price')
        nome = $(this).attr('nome')
        $.post('https://pb_cardealer/SpawnCar', JSON.stringify({modelo: model, tipo:id}))
        $(".listE").css("background-color", "rgba(19, 19, 19, 0.767)")
        $(this).css("background", "rgba(18, 103, 231, 0.884)")
        $('.list').remove()
        $('.listComp').remove()
        $('.container').append('<li id = "listComp" class="listComp">Comprar</li><li id="lista" class="list">Testar<p>' + price/100 + '€</p></li>')
        Selected ()
    })
}

function Selected () {
    $("#lista").click(function(){
        $.post('https://pb_cardealer/TestDrive', JSON.stringify({modelo: model, price: (price/100)}))
    })

    $("#listComp").click(function(){
        $.post('https://pb_cardealer/BuyVehicle', JSON.stringify({nome: nome, modelo: model, price: (price/1)}))
    })
}

$(document).keyup(function(e){
    if (e.key == "Escape") {
        Close()
    }
});


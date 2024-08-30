({
    doinit : function(component, event, helper){
        component.set("v.showtabOne",true);
    },
    ShowFirsttab :function(component, event, helper){
        debugger;
        var boxDiv = component.find('box1');
        $A.util.addClass(boxDiv, 'selTab');
        component.set("v.showtabOne",true);
        var box2Div = component.find('box2');
        var box3Div = component.find('box3');
        var box4Div = component.find('box4');
        var box5Div = component.find('box5');
        $A.util.removeClass(box2Div, 'selTab');
        $A.util.removeClass(box3Div, 'selTab');
        $A.util.removeClass(box4Div, 'selTab');
        $A.util.removeClass(box5Div, 'selTab');
        
        component.set("v.showtabTwo",false);
        component.set("v.showtabthree",false);
        component.set("v.showtabfour",false);
        component.set("v.showtabfive",false);
    },
    ShowSecondtab :function(component, event, helper){
        debugger;
        var boxDiv = component.find('box2');
        $A.util.addClass(boxDiv, 'selTab');
        component.set("v.showtabOne",false);
        component.set("v.showtabTwo",true);
        var box1Div = component.find('box1');
        var box3Div = component.find('box3');
        var box4Div = component.find('box4');
        var box5Div = component.find('box5');
        $A.util.removeClass(box1Div, 'selTab');
        $A.util.removeClass(box3Div, 'selTab');
        $A.util.removeClass(box4Div, 'selTab');
        $A.util.removeClass(box5Div, 'selTab');
        //component.set("v.showtabTwo",true);
        component.set("v.showtabthree",false);
        component.set("v.showtabfour",false);
        component.set("v.showtabfive",false);
    },
    Showthirdtab :function(component, event, helper){
        debugger;
        var boxDiv = component.find('box3');
        $A.util.addClass(boxDiv, 'selTab');
        component.set("v.showtabOne",false);
        component.set("v.showtabTwo",false);
        component.set("v.showtabthree",true);
        var box1Div = component.find('box1');
        var box2Div = component.find('box2');
        var box4Div = component.find('box4');
        var box5Div = component.find('box5');
        $A.util.removeClass(box1Div, 'selTab');
        $A.util.removeClass(box2Div, 'selTab');
        $A.util.removeClass(box4Div, 'selTab');
        $A.util.removeClass(box5Div, 'selTab');
        component.set("v.showtabfour",false);
        component.set("v.showtabfive",false);
    },
    Showfourtab :function(component, event, helper){
        debugger;
        var boxDiv = component.find('box4');
        $A.util.addClass(boxDiv, 'selTab');
        component.set("v.showtabOne",false);
        component.set("v.showtabTwo",false);
        component.set("v.showtabthree",false);
        component.set("v.showtabfour",true);
        var box1Div = component.find('box1');
        var box2Div = component.find('box2');
        var box3Div = component.find('box3');
        var box5Div = component.find('box5');
        $A.util.removeClass(box1Div, 'selTab');
        $A.util.removeClass(box2Div, 'selTab');
        $A.util.removeClass(box3Div, 'selTab');
        $A.util.removeClass(box5Div, 'selTab');
        component.set("v.showtabfive",false);
    },
    Showfivetab :function(component, event, helper){
        debugger;
        var boxDiv = component.find('box5');
        $A.util.addClass(boxDiv, 'selTab');
        component.set("v.showtabOne",false);
        component.set("v.showtabTwo",false);
        component.set("v.showtabthree",false);
        component.set("v.showtabfour",false);
        component.set("v.showtabfive",true);
        var box1Div = component.find('box1');
        var box2Div = component.find('box2');
        var box3Div = component.find('box3');
        var box4Div = component.find('box4');
        $A.util.removeClass(box1Div, 'selTab');
        $A.util.removeClass(box2Div, 'selTab');
        $A.util.removeClass(box3Div, 'selTab');
        $A.util.removeClass(box4Div, 'selTab');
    },
})
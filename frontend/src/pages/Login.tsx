function Login() {
    function doLogin(event:any) : void {
        event.preventDefault();
        alert('Log In'); //placeholder for now
    }
    return(
    <div id="loginDiv">
        <span id="inner-title">PLEASE LOG IN</span><br />
        <input type="text" id="loginName" placeholder="Username" /><br />
        <input type="password" id="loginPassword" placeholder="Password" /><br />
        <input type="submit" id="loginButton" className="buttons" value = "Log In" onClick={doLogin} />
        <span id="loginResult"></span>
    </div>
    );
};

export default Login;
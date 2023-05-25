import React from "react";
import "./styles.css";

class Main extends Component {
  render() {
    const { text } = this.props.text;

    return (
      <div className="container-fluid text-monospace main">
        <br />
        &nbsp;
        <br />
        <div className="row">
          <div className="col-md-10">
            {text.map((item, index) => (
              <p key={index}>{item}</p>
            ))}
          </div>
        </div>
      </div>
    );
  }
}


import "./Popup.css";

interface Props {
  onClose: () => void;
}

function Popup({ onClose }: Props) {
  return (
    <div className="modalPopUp">
      
          <button className="close" onClick={onClose}>
            Send it
          </button>
      
    </div>
  );
};

export default Popup;